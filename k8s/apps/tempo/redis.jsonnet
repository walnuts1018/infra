{
  apiVersion: 'redis.redis.opstreelabs.in/v1beta2',
  kind: 'RedisCluster',
  metadata: {
    name: (import 'app.json5').name + '-redis',
    labels: (import '../../components/labels.libsonnet')($.metadata.name),
  },
  spec: {
    clusterSize: 3,
    clusterVersion: 'v7',
    persistenceEnabled: true,
    kubernetesConfig: {
      image: 'quay.io/opstree/redis:v8.4.0',
      imagePullPolicy: 'IfNotPresent',
      resources: {
        requests: {
          cpu: '5m',
          memory: '5Mi',
        },
        limits: {
          cpu: '1',
          memory: '1Gi',
        },
      },
    },
    storage: {
      volumeClaimTemplate: {
        spec: {
          accessModes: [
            'ReadWriteOnce',
          ],
          resources: {
            requests: {
              storage: '1Gi',
            },
          },
        },
      },
    },
    podSecurityContext: {
      fsGroup: 1000,
      runAsUser: 1000,
    },
  },
}
