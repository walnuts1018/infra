{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'Seaweed',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    image: 'chrislusf/seaweedfs:4.05',
    master: {
      replicas: 3,
      volumeSizeLimitMB: 1024,
    },
    volume: {
      replicas: 0,
      requests: {
        cpu: '100m',
        memory: '512Mi',
        storage: '2Gi',
      },
      limits: {
        cpu: '1',
        memory: '2Gi',
      },
      storageClassName: 'local-path',
    },
    volumeTopology: {
      'iwakura-rack1': {
        replicas: 3,
        dataCenter: 'iwakura',
        rack: 'rack1',
        nodeSelector: {
          'topology.kubernetes.io/region': 'ap-japan-kansai',
          'topology.kubernetes.io/zone': 'iwakura',
          'topology.kubernetes.io/rack': 'rack1',
        },
      },
    },
    filer: {
      replicas: 2,
      s3: {
        enabled: true,
      },
      requests: {
        cpu: '100m',
        memory: '128Mi',
      },
      limits: {
        cpu: '200m',
        memory: '256Mi',
      },
      service: {
        type: 'ClusterIP',
      },
      config: |||
        [leveldb2]
        enabled = true
        dir = "/data/filerldb2"
      |||,
    },
  },
}
