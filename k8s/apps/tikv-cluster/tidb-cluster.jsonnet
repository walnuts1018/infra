local app = import 'app.json5';
local componentAffinity(component) = {
  podAntiAffinity: {
    requiredDuringSchedulingIgnoredDuringExecution: [
      {
        labelSelector: {
          matchLabels: {
            'app.kubernetes.io/component': component,
            'app.kubernetes.io/instance': app.name,
          },
        },
        topologyKey: 'kubernetes.io/hostname',
      },
    ],
  },
};
{
  apiVersion: 'pingcap.com/v1alpha1',
  kind: 'TidbCluster',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    version: 'v8.5.7',
    timezone: 'Asia/Tokyo',
    pvReclaimPolicy: 'Retain',
    enableDynamicConfiguration: true,
    configUpdateStrategy: 'RollingUpdate',
    tlsCluster: {
      enabled: true,
    },
    discovery: {},
    helper: {
      image: 'alpine:3.16.0',
    },
    pd: {
      baseImage: 'pingcap/pd',
      replicas: 3,
      maxFailoverCount: 0,
      storageClassName: 'local-path',
      requests: {
        cpu: '50m',
        memory: '100Mi',
        storage: '1Gi',
      },
      limits: {
        memory: '512Mi',
      },
      affinity: componentAffinity('pd'),
      config: |||
        [security]
          cert-allowed-cn = [ "TiDB", "SeaweedFS" ]
      |||,
    },
    tikv: {
      baseImage: 'pingcap/tikv',
      replicas: 3,
      maxFailoverCount: 0,
      storageClassName: 'local-path',
      requests: {
        cpu: '30m',
        memory: '384Mi',
        storage: '8Gi',
      },
      limits: {
        memory: '2Gi',
      },
      env: [
        {
          name: 'MALLOC_CONF',
          value: 'narenas:8,background_thread:true,dirty_decay_ms:1000,muzzy_decay_ms:1000',
        },
      ],
      affinity: componentAffinity('tikv'),
      config: |||
        memory-usage-limit = "1GiB"

        [memory]
          enable-thread-exclusive-arena = false

        [storage.block-cache]
          capacity = "256MiB"

        [rocksdb.defaultcf]
          write-buffer-size = "32MiB"

        [rocksdb.writecf]
          write-buffer-size = "32MiB"

        [rocksdb.raftcf]
          write-buffer-size = "32MiB"

        [rocksdb.lockcf]
          write-buffer-size = "8MiB"

        [security]
          cert-allowed-cn = [ "TiDB", "SeaweedFS" ]
      |||,
    },
  },
}
