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
        cpu: '100m',
        memory: '256Mi',
        storage: '1Gi',
      },
      limits: {
        cpu: '500m',
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
        cpu: '10m',
        memory: '1Gi',
        storage: '8Gi',
      },
      limits: {
        cpu: '2',
        memory: '2Gi',
      },
      affinity: componentAffinity('tikv'),
      config: |||
        [memory]
          enable-thread-exclusive-arena = false

        [security]
          cert-allowed-cn = [ "TiDB", "SeaweedFS" ]
      |||,
    },
  },
}
