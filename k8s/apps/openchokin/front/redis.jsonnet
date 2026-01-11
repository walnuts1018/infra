[
  {
    apiVersion: 'redis.redis.opstreelabs.in/v1beta2',
    kind: 'RedisReplication',
    metadata: {
      name: (import '../app.json5').name + '-front-redis',
      labels: (import '../../../components/labels.libsonnet')((import '../app.json5').name + '-front-redis'),
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
      name: (import '../app.json5').name + '-front-redis',
      labels: (import '../../../components/labels.libsonnet')((import '../app.json5').name + '-front-redis'),
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
        image: 'quay.io/opstree/redis-sentinel:v7.4.7',
        imagePullPolicy: 'IfNotPresent',
        redisSecret: {
          name: (import '../external-secret.jsonnet').spec.target.name,
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
      tolerations: [
        {
          key: 'node.walnuts.dev/low-performance',
          operator: 'Exists',
        },
      ],
      podSecurityContext: {
        fsGroup: 1000,
        runAsUser: 1000,
      },
    },
  },
]
