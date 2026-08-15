local app = import 'app.json5';
{
  apiVersion: 'redis.redis.opstreelabs.in/v1beta2',
  kind: 'Redis',
  metadata: {
    name: app.name + '-redis',
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name + '-redis'),
  },
  spec: {
    kubernetesConfig: {
      image: 'quay.io/opstree/redis:v7.4.8',
      imagePullPolicy: 'IfNotPresent',
      redisSecret: {
        name: (import 'external-secret.jsonnet').spec.target.name,
        key: 'redis_password',
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
              storage: '2Gi',
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
