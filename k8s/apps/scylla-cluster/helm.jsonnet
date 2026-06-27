local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local configmapScyllaConfig = import 'configmap-scylla-config.jsonnet';
function(enableServiceMonitor=true) (helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'scylla',
  repoURL: 'https://scylla-operator-charts.storage.googleapis.com/stable',
  targetRevision: 'v1.21.0',
  valuesObject: {
    developerMode: true,
    scyllaImage: {
      repository: 'scylladb/scylla',
      tag: '2025.4.7',  // TODO: Operatorのサポートバージョンがあるので、手動で指定するのをやめる？
    },
    datacenter: 'iwakura',
    racks: [
      {
        name: 'iwakura-a',
        scyllaConfig: configmapScyllaConfig.metadata.name,
        members: 3,
        storage: {
          storageClassName: 'local-path',
          capacity: '8Gi',
        },
        resources: {
          requests: {
            cpu: '30m',
            memory: '512Mi',
          },
          limits: {
            cpu: '1',
            memory: '4Gi',
          },
        },
        placement: {
          nodeAffinity: {},
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
