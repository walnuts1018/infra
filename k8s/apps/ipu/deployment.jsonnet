local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local envoyConfig = import 'configmap-envoy.jsonnet';
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
        annotations: {
          'checksum/config': std.md5(envoyConfig.data['envoy.yaml']),
        },
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
        initContainers: [
          {
            name: 's3-credentials',
            image: 'docker.io/library/busybox:1.37.0',
            imagePullPolicy: 'IfNotPresent',
            restartPolicy: 'Always',
            command: ['/bin/sh', '-c'],
            args: [
              |||
                set -eu
                umask 077

                credentials_dir=/var/run/aws
                credentials_file="${credentials_dir}/credentials"
                secret_dir=/var/run/s3-credentials

                while true; do
                  access_key="$(cat "${secret_dir}/AWS_ACCESS_KEY_ID" 2>/dev/null || true)"
                  secret_key="$(cat "${secret_dir}/AWS_SECRET_ACCESS_KEY" 2>/dev/null || true)"
                  if [ -n "${access_key}" ] && [ -n "${secret_key}" ]; then
                    printf '[default]\naws_access_key_id = %s\naws_secret_access_key = %s\n' "${access_key}" "${secret_key}" > "${credentials_file}.tmp"
                    chmod 0640 "${credentials_file}.tmp"
                    mv -f "${credentials_file}.tmp" "${credentials_file}"
                  fi
                  sleep 30
                done
              |||,
            ],
            startupProbe: {
              exec: {
                command: ['/bin/sh', '-c', 'test -s /var/run/aws/credentials'],
              },
              periodSeconds: 2,
              failureThreshold: 90,
            },
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: { drop: ['ALL'] },
              readOnlyRootFilesystem: true,
              runAsNonRoot: true,
              runAsUser: 65532,
              runAsGroup: 65532,
            },
            resources: {
              requests: { cpu: '5m', memory: '64Mi' },
              limits: { memory: '256Mi' },
            },
            volumeMounts: [
              { name: 's3-credentials', mountPath: '/var/run/s3-credentials', readOnly: true },
              { name: 'aws-credentials', mountPath: '/var/run/aws' },
              { name: 'tmp', mountPath: '/tmp' },
            ],
          },
        ],
        containers: [
          {
            name: 'envoy',
            image: 'docker.io/envoyproxy/envoy:distroless-v1.39.0',
            imagePullPolicy: 'IfNotPresent',
            command: ['envoy'],
            args: ['-c', '/etc/envoy/envoy.yaml'],
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
              { name: 'aws-credentials', mountPath: '/var/run/aws', readOnly: true },
              { name: 'tmp', mountPath: '/tmp' },
            ],
          },
        ],
        volumes: [
          {
            name: 'envoy-config',
            configMap: { name: envoyConfig.metadata.name },
          },
          {
            name: 'aws-credentials',
            emptyDir: { medium: 'Memory' },
          },
          { name: 'tmp', emptyDir: {} },
          {
            name: 's3-credentials',
            secret: { secretName: app.name + '-s3-credentials' },
          },
        ],
      },
    },
  },
}
