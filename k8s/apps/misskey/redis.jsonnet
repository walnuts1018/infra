{
  apiVersion: 'redis.redis.opstreelabs.in/v1beta2',
  kind: 'Redis',
  metadata: {
    name: 'misskey-redis',
    labels: {
      'app.kubernetes.io/name': 'misskey-redis',
    },
  },
  spec: {
    kubernetesConfig: {
      image: 'quay.io/opstree/redis:v7.2.7',
      imagePullPolicy: 'IfNotPresent',
      redisSecret: {
        name: (import 'external-secret.jsonnet').spec.target.name,
        key: 'redisPassword',
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
    nodeSelector: {
      'kubernetes.io/arch': 'amd64',
    },
  },
}
