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
      image: 'quay.io/opstree/redis:v7.0.12',
      imagePullPolicy: 'IfNotPresent',
      redisSecret: {
        name: (import 'external-secret.jsonnet').metadata.name,
        key: 'redispassword',
      },
    },
    storage: {
    },
    podSecurityContext: {
      fsGroup: 1000,
      runAsUser: 1000,
    },
  },
}
