{
  name:: error 'name is required',
  secret_name:: error 'secret_name is required',
  items: [
    {
      apiVersion: 'redis.redis.opstreelabs.in/v1beta2',
      kind: 'RedisReplication',
      metadata: {
        name: $.name,
        labels: (import '../labels.libsonnet') { appname: $.name },
      },
      spec: {
        clusterSize: 2,
        kubernetesConfig: {
          image: 'quay.io/opstree/redis:v7.0.12',
          imagePullPolicy: 'IfNotPresent',
          redisSecret: {
            name: $.secret_name,
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
    },
    {
      apiVersion: 'redis.redis.opstreelabs.in/v1beta2',
      kind: 'RedisSentinel',
      metadata: {
        name: $.name,
        labels: (import '../labels.libsonnet') { appname: $.name },
      },
      spec: {
        clusterSize: 3,
        redisSentinelConfig: {
          redisReplicationName: $.name,
          masterGroupName: 'mymaster',
          redisPort: '6379',
          quorum: '2',
          parallelSyncs: '1',
          failoverTimeout: '180000',
          downAfterMilliseconds: '30000',
        },
        kubernetesConfig: {
          image: 'quay.io/opstree/redis-sentinel:v7.2.6',
          imagePullPolicy: 'IfNotPresent',
          redisSecret: {
            name: $.secret_name,
            key: 'redis-password',
          },
        },
        podSecurityContext: {
          fsGroup: 1000,
          runAsUser: 1000,
        },
      },
    },
  ],
}
