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
          image: 'quay.io/opstree/redis:v7.2.7',
          imagePullPolicy: 'IfNotPresent',
          redisSecret: {
            name: $.secret_name,
            key: 'redis-password',
          },
          resources: {
            requests: {
              cpu: '4m',
              memory: '4Mi',
            },
            limits: {
              cpu: '100m',
              memory: '128Mi',
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
          image: 'quay.io/opstree/redis-sentinel:v7.2.7',
          imagePullPolicy: 'IfNotPresent',
          redisSecret: {
            name: $.secret_name,
            key: 'redis-password',
          },
          resources: {
            requests: {
              cpu: '4m',
              memory: '4Mi',
            },
            limits: {
              cpu: '100m',
              memory: '128Mi',
            },
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
