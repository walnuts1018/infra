{
  apiVersion: 'moco.cybozu.com/v1beta2',
  kind: 'MySQLCluster',
  metadata: {
    name: (import 'app.json5').name,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    replicas: 3,
    podTemplate: {
      spec: {
        affinity: {
          nodeAffinity: {
            preferredDuringSchedulingIgnoredDuringExecution: [
              {
                weight: 100,
                preference: {
                  matchExpressions: [
                    {
                      key: 'kubernetes.io/arch',
                      operator: 'In',
                      values: [
                        'amd64',
                      ],
                    },
                  ],
                },
              },
            ],
          },
          podAntiAffinity: {
            requiredDuringSchedulingIgnoredDuringExecution: [
              {
                labelSelector: {
                  matchExpressions: [
                    {
                      key: 'app.kubernetes.io/instance',
                      operator: 'In',
                      values: [
                        'test',
                      ],
                    },
                  ],
                },
                topologyKey: 'kubernetes.io/hostname',
              },
            ],
            preferredDuringSchedulingIgnoredDuringExecution: [
              {
                weight: 10,
                podAffinityTerm: {
                  labelSelector: {
                    matchExpressions: [
                      {
                        key: 'app.kubernetes.io/name',
                        operator: 'In',
                        values: [
                          'mysql',
                        ],
                      },
                    ],
                  },
                  topologyKey: 'kubernetes.io/hostname',
                },
              },
            ],
          },
        },
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'mysqld',
            image: 'ghcr.io/cybozu-go/moco/mysql:8.4.5',
            resources: {
              requests: {
                memory: '400Mi',
              },
              limits: {
                memory: '2Gi',
              },
            },
          },
        ],
      },
    },
    volumeClaimTemplates: [
      {
        metadata: {
          name: 'mysql-data',
        },
        spec: {
          accessModes: [
            'ReadWriteOnce',
          ],
          storageClassName: 'longhorn',
          resources: {
            requests: {
              storage: '1Gi',
            },
          },
        },
      },
    ],
    primaryServiceTemplate: {
      spec: {
        type: 'LoadBalancer',
        loadBalancerIP: '192.168.0.133',
      },
    },
  },
}
