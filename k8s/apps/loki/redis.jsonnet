{
  apiVersion: 'redis.redis.opstreelabs.in/v1beta2',
  kind: 'RedisCluster',
  metadata: {
    name: (import 'app.json5').name + '-redis',
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name + '-redis' },
  },
  spec: {
    clusterSize: 3,
    clusterVersion: 'v7',
    persistenceEnabled: true,
    kubernetesConfig: {
      image: 'quay.io/opstree/redis:v8.2.1',
      imagePullPolicy: 'IfNotPresent',
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
