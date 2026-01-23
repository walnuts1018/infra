function(enableServiceMonitor=true) (import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'scylla',
  repoURL: 'https://scylla-operator-charts.storage.googleapis.com/stable',
  targetRevision: 'v1.19.0',
  valuesObject: {
    developerMode: true,
    scyllaImage: {
      repository: 'scylladb/scylla',
      tag: '2025.4.2',  // TODO: Operatorのサポートバージョンがあるので、手動で指定するのをやめる？
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
            cpu: '30m',
            memory: '256Mi',
          },
          limits: {
            cpu: '1',
            memory: '3Gi',
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
