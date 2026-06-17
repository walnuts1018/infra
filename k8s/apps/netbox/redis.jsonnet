{
  apiVersion: 'redis.redis.opstreelabs.in/v1beta2',
  kind: 'Redis',
  metadata: {
    name: (import 'app.json5').name + '-redis',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name + '-redis'),
  },
  spec: {
    kubernetesConfig: {
      image: 'quay.io/opstree/redis:v7.4.8',
      imagePullPolicy: 'IfNotPresent',
      redisSecret: {
        name: (import 'external-secret.jsonnet').spec.target.name,
        key: 'redis-password',
      },
      resources: {
        requests: {
          cpu: '5m',
          memory: '16Mi',
        },
        limits: {
          cpu: '500m',
          memory: '256Mi',
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
