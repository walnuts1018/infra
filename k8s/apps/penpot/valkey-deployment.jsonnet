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
        nodeSelector: {
          'kubernetes.io/hostname': 'rusk',
        },
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
            image: 'valkey/valkey:9.1.3@sha256:3add1a336a920ea54770a001ab6feb3da5fceea96a40373a3a2cd469b815f0b7',
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
                cpu: '5m',
                memory: '16Mi',
              },
              limits: {
                cpu: '100m',
                memory: '256Mi',
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
