local app = import 'app.json5';
local valkeyLabels = (import '../../components/labels.libsonnet')(app.name + '-valkey') + {
  'app.kubernetes.io/instance': app.name,
};
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-valkey',
    namespace: app.namespace,
    labels: valkeyLabels,
  },
  spec: {
    replicas: 1,
    strategy: {
      type: 'Recreate',
    },
    selector: {
      matchLabels: valkeyLabels,
    },
    template: {
      metadata: {
        labels: valkeyLabels,
      },
      spec: {
        serviceAccountName: app.name,
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 10001,
          runAsGroup: 10001,
          fsGroup: 10001,
          seccompProfile: {
            type: 'RuntimeDefault',
          },
        },
        containers: [
          {
            name: 'valkey',
            image: 'valkey/valkey:9.1.2@sha256:418652cfb58ef879d4978c33553735d7147016032d5aefaa14c828e611eb9dfd',
            imagePullPolicy: 'IfNotPresent',
            command: ['valkey-server'],
            args: [
              '--maxmemory',
              '256mb',
              '--maxmemory-policy',
              'volatile-lfu',
              '--appendonly',
              'no',
              '--save',
              '',
              '--requirepass',
              '$(REDIS_PASSWORD)',
            ],
            env: [
              {
                name: 'REDIS_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').metadata.name,
                    key: 'redis-password',
                  },
                },
              },
            ],
            ports: [
              {
                name: 'valkey',
                containerPort: 6379,
                protocol: 'TCP',
              },
            ],
            readinessProbe: {
              exec: {
                command: ['sh', '-c', 'valkey-cli -a "$REDIS_PASSWORD" ping'],
              },
              initialDelaySeconds: 5,
              periodSeconds: 5,
            },
            livenessProbe: {
              exec: {
                command: ['sh', '-c', 'valkey-cli -a "$REDIS_PASSWORD" ping'],
              },
              initialDelaySeconds: 15,
              periodSeconds: 10,
            },
            securityContext: {
              runAsNonRoot: true,
              runAsUser: 10001,
              runAsGroup: 10001,
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: true,
              capabilities: {
                drop: ['ALL'],
              },
            },
            resources: {
              requests: {
                cpu: '10m',
                memory: '128Mi',
              },
              limits: {
                cpu: '500m',
                memory: '384Mi',
              },
            },
            volumeMounts: [
              {
                name: 'data',
                mountPath: '/data',
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'data',
            emptyDir: {},
          },
        ],
      },
    },
  },
}
