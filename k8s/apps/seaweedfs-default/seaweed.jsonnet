{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'Seaweed',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    image: 'ghcr.io/walnuts1018/seaweedfs:dev',  // TODO: filerがpanicするのでdev使ってみる
    master: {
      replicas: 3,
      volumeSizeLimitMB: 1024,
    },
    // TODO: volumeTopology使いたいけど、ServiceのSelectorがバグってる気がする
    volume: {
      replicas: 3,
      requests: {
        cpu: '100m',
        memory: '128Mi',
        storage: '2Gi',
      },
      limits: {
        cpu: '1',
        memory: '2Gi',
      },
      storageClassName: 'local-path',
      affinity: {
        local labels = {
          'app.kubernetes.io/component': 'volume',
          'app.kubernetes.io/instance': $.metadata.name,
        },
        podAntiAffinity: {
          requiredDuringSchedulingIgnoredDuringExecution: [
            {
              labelSelector: {
                matchLabels: labels,
              },
              topologyKey: 'kubernetes.io/hostname',
            },
          ],
          preferredDuringSchedulingIgnoredDuringExecution: [
            {
              weight: 50,
              podAffinityTerm: {
                labelSelector: {
                  matchLabels: labels,
                },
                topologyKey: 'topology.kubernetes.io/zone',
              },
            },
            {
              weight: 40,
              podAffinityTerm: {
                labelSelector: {
                  matchLabels: labels,
                },
                topologyKey: 'kubernetes.io/region',
              },
            },
          ],
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
      config: (importstr '_config/filer.toml'),
    },
  },
}
