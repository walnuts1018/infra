local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local envoyConfig = import 'configmap.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name),
    },
    strategy: {
      type: 'RollingUpdate',
      rollingUpdate: {
        maxUnavailable: 0,
        maxSurge: 1,
      },
    },
    template: {
      metadata: {
        labels: labels(app.name),
      },
      spec: {
        serviceAccountName: (import 'sa.jsonnet').metadata.name,
        automountServiceAccountToken: false,
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 65532,
          runAsGroup: 65532,
          fsGroup: 65532,
          fsGroupChangePolicy: 'OnRootMismatch',
          seccompProfile: {
            type: 'RuntimeDefault',
          },
        },
        containers: [
          {
            name: 'envoy',
            image: 'docker.io/envoyproxy/envoy:distroless-v1.39.0@sha256:7877ad87afd7459e1bd2a077ff601fec7c93aeecd62e71664560d96328c62cf4',
            imagePullPolicy: 'IfNotPresent',
            command: ['envoy'],
            args: ['-c', '/etc/envoy/envoy.yaml'],
            env: [
              {
                name: 'AWS_ACCESS_KEY_ID',
                valueFrom: {
                  secretKeyRef: {
                    name: app.name + '-s3-credentials',
                    key: 'AWS_ACCESS_KEY_ID',
                  },
                },
              },
              {
                name: 'AWS_SECRET_ACCESS_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: app.name + '-s3-credentials',
                    key: 'AWS_SECRET_ACCESS_KEY',
                  },
                },
              },
            ],
            ports: [
              {
                name: 'http',
                containerPort: 8080,
                protocol: 'TCP',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/livez',
                port: 'http',
              },
            },
            readinessProbe: {
              httpGet: {
                path: '/readyz',
                port: 'http',
              },
            },
            resources: {
              limits: {
                memory: '256Mi',
              },
              requests: {
                cpu: '30m',
                memory: '48Mi',
              },
            },
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: { drop: ['ALL'] },
              readOnlyRootFilesystem: true,
              runAsNonRoot: true,
              runAsUser: 65532,
              runAsGroup: 65532,
            },
            volumeMounts: [
              {
                name: 'envoy-config',
                mountPath: '/etc/envoy',
                readOnly: true,
              },
              { name: 'tmp', mountPath: '/tmp' },
            ],
          },
        ],
        volumes: [
          {
            name: 'envoy-config',
            configMap: { name: envoyConfig.metadata.name },
          },
          { name: 'tmp', emptyDir: {} },
        ],
      },
    },
  },
}
