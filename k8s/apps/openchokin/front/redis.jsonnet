[
  {
    apiVersion: 'redis.redis.opstreelabs.in/v1beta2',
    kind: 'RedisReplication',
    metadata: {
      name: (import '../app.json5').name + '-front-redis',
      labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-front-redis' },
    },
    spec: {
      clusterSize: 2,
      kubernetesConfig: {
        image: 'quay.io/opstree/redis:v7.2.7',
        imagePullPolicy: 'IfNotPresent',
        redisSecret: {
          name: (import '../external-secret.jsonnet').spec.target.name,
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
      nodeSelector: {
        'kubernetes.io/arch': 'amd64',
      },
    },
  },
  {
    apiVersion: 'redis.redis.opstreelabs.in/v1beta2',
    kind: 'RedisSentinel',
    metadata: {
      name: (import '../app.json5').name + '-front-redis',
      labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-front-redis' },
    },
    spec: {
      clusterSize: 3,
      redisSentinelConfig: {
        redisReplicationName: 'openchokin-front-redis',
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
          name: (import '../external-secret.jsonnet').spec.target.name,
          key: 'redis-password',
        },
      },
      podSecurityContext: {
        fsGroup: 1000,
        runAsUser: 1000,
      },
    },
  },
]
