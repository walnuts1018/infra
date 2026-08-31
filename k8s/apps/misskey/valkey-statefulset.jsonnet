// TODO: valkey-operatorがNot Clusterをサポートするようになったらそちらに移行する
local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local externalSecret = import 'external-secret.jsonnet';
local valkeyLabels = labels(app.name + '-valkey');
{
  apiVersion: 'apps/v1',
  kind: 'StatefulSet',
  metadata: {
    name: app.name + '-valkey',
    namespace: app.namespace,
    labels: valkeyLabels,
  },
  spec: {
    serviceName: app.name + '-valkey-headless',
    replicas: 1,
    selector: {
      matchLabels: valkeyLabels,
    },
    template: {
      metadata: {
        labels: valkeyLabels,
      },
      spec: {
        affinity: (import '../../components/storage.libsonnet').avoidSlowNodeAffinity,
        securityContext: {
          fsGroup: 999,
          fsGroupChangePolicy: 'OnRootMismatch',
        },
        containers: [
          (container) {
            name: 'valkey',
            image: 'valkey/valkey:9.0.0',
            imagePullPolicy: 'IfNotPresent',
            command: ['valkey-server'],
            args: [
              '--maxmemory-policy',
              'noeviction',
              '--requirepass',
              '$(REDIS_PASSWORD)',
            ],
            env: [
              {
                name: 'REDIS_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'redisPassword',
                  },
                },
              },
            ],
            ports: [
              {
                name: 'valkey',
                containerPort: 6379,
              },
            ],
            readinessProbe: {
              exec: {
                command: [
                  'sh',
                  '-c',
                  'valkey-cli -a "$REDIS_PASSWORD" ping',
                ],
              },
              initialDelaySeconds: 5,
              periodSeconds: 5,
            },
            livenessProbe: {
              exec: {
                command: [
                  'sh',
                  '-c',
                  'valkey-cli -a "$REDIS_PASSWORD" ping',
                ],
              },
              initialDelaySeconds: 15,
              periodSeconds: 10,
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
      },
    },
    volumeClaimTemplates: [
      {
        metadata: {
          name: 'data',
        },
        spec: {
          accessModes: ['ReadWriteOnce'],
          storageClassName: 'longhorn',
          resources: {
            requests: {
              storage: '1Gi',
            },
          },
        },
      },
    ],
  },
}
