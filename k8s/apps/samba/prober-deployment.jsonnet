local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local secretName = (import 'external-secret.jsonnet').spec.target.name;
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'samba-prober',
    namespace: app.namespace,
    labels: labels('samba-prober'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels('samba-prober'),
    },
    template: {
      metadata: {
        labels: labels('samba-prober'),
        annotations: {
          'checksum/samba-monitor-config': std.md5(std.toString((import 'monitor-configmap.jsonnet').data)),
        },
      },
      spec: {
        automountServiceAccountToken: false,
        securityContext: {
          fsGroup: 1000,
          fsGroupChangePolicy: 'OnRootMismatch',
          runAsGroup: 1000,
          runAsNonRoot: true,
          runAsUser: 1000,
          seccompProfile: {
            type: 'RuntimeDefault',
          },
        },
        containers: [
          {
            name: 'prober',
            image: 'ghcr.io/servercontainers/samba:a3.24.2-s4.23.8-r0@sha256:ea1b37536729f16b2f45a601ea45a37d34b9fce5cc51f2d686a347dd77131be1',
            imagePullPolicy: 'IfNotPresent',
            command: ['/bin/sh', '/config/probe.sh'],
            ports: [
              {
                name: 'metrics',
                containerPort: 9187,
              },
            ],
            readinessProbe: {
              httpGet: {
                path: '/metrics',
                port: 'metrics',
              },
              periodSeconds: 10,
              timeoutSeconds: 2,
            },
            livenessProbe: {
              httpGet: {
                path: '/metrics',
                port: 'metrics',
              },
              initialDelaySeconds: 30,
              periodSeconds: 30,
              timeoutSeconds: 2,
            },
            securityContext: {
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: true,
              capabilities: {
                drop: ['ALL'],
              },
            },
            volumeMounts: [
              {
                name: 'probe-config',
                mountPath: '/config',
                readOnly: true,
              },
              {
                name: 'monitor-credentials',
                mountPath: '/run/secrets',
                readOnly: true,
              },
              {
                name: 'probe-auth',
                mountPath: '/run/probe-auth',
              },
              {
                name: 'metrics',
                mountPath: '/tmp/www',
              },
            ],
            resources: {
              requests: {
                cpu: '10m',
                memory: '64Mi',
              },
              limits: {
                cpu: '100m',
                memory: '256Mi',
              },
            },
          },
        ],
        volumes: [
          {
            name: 'probe-config',
            configMap: {
              name: 'samba-monitor',
            },
          },
          {
            name: 'monitor-credentials',
            secret: {
              secretName: secretName,
              defaultMode: 288,
              items: [
                {
                  key: 'monitor-username',
                  path: 'username',
                },
                {
                  key: 'monitor-password',
                  path: 'password',
                },
              ],
            },
          },
          {
            name: 'probe-auth',
            emptyDir: {
              medium: 'Memory',
              sizeLimit: '1Mi',
            },
          },
          {
            name: 'metrics',
            emptyDir: {
              medium: 'Memory',
              sizeLimit: '1Mi',
            },
          },
        ],
      },
    },
  },
}
