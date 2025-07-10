{
  apiVersion: 'redis.redis.opstreelabs.in/v1beta2',
  kind: 'Redis',
  metadata: {
    local appname = (import 'app.json5').name + '-redis',
    name: appname,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: appname },

  },
  spec: {
    kubernetesConfig: {
      image: 'quay.io/opstree/redis:v7.2.7',
      imagePullPolicy: 'IfNotPresent',
      redisSecret: {
        name: (import 'external-secret.jsonnet').spec.target.name,
        key: 'redispassword',
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
