{
  apiVersion: 'redis.redis.opstreelabs.in/v1beta2',
  kind: 'Redis',
  metadata: {
    name: 'nextcloud-redis',
    labels: {
      'app.kubernetes.io/name': 'nextcloud-redis',
    },
  },
  spec: {
    kubernetesConfig: {
      image: 'quay.io/opstree/redis:7.4.1',
      imagePullPolicy: 'IfNotPresent',
      redisSecret: {
        name: (import 'external-secret.jsonnet').name,
        key: 'redis-password',
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
