local storage = import '../../components/storage.libsonnet';
local app = import 'app.json5';
function(enableServiceMonitor=true) (import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'scylla',
  repoURL: 'https://scylla-operator-charts.storage.googleapis.com/stable',
  targetRevision: 'v1.22.0',
  valuesObject: {
    developerMode: true,
    scyllaImage: {
      repository: 'scylladb/scylla',
      tag: '2025.4.10',  // TODO: Operatorのサポートバージョンがあるので、手動で指定するのをやめる？
    },
    datacenter: 'iwakura',
    racks: [
      {
        name: 'iwakura-a',
        scyllaConfig: (import 'configmap-scylla-config.jsonnet').metadata.name,
        members: 3,
        storage: {
          storageClassName: 'local-path',
          capacity: '8Gi',
        },
        resources: {
          requests: {
            cpu: '20m',
            memory: '300Mi',
          },
          limits: {
            cpu: '1',  // なんかoperatorがlimitつけろってうるさいのでつける
            memory: '2Gi',
          },
        },
        placement: {
          nodeAffinity: storage.avoidSlowNodeAffinity.nodeAffinity,
          podAffinity: {},
          podAntiAffinity: {
            preferredDuringSchedulingIgnoredDuringExecution: [
              {
                weight: 100,
                podAffinityTerm: {
                  labelSelector: {
                    matchExpressions: [
                      {
                        key: 'scylla/cluster',
                        operator: 'In',
                        values: [
                          'scylla-cluster',
                        ],
                      },
                    ],
                  },
                  topologyKey: 'kubernetes.io/hostname',
                },
              },
            ],
          },
          tolerations: [],
        },
      },
    ],
    serviceMonitor: {
      create: true,
    },
  },
}
