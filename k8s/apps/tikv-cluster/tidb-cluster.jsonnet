local storage = import '../../components/storage.libsonnet';
local app = import 'app.json5';
local componentAffinity(component) = {
  nodeAffinity: storage.avoidSlowNodeAffinity.nodeAffinity,
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
      image: 'alpine:3.24.1',
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
          cert-allowed-cn = ["TiDB", "SeaweedFS"]
      |||,
    },
    tikv: {
      baseImage: 'pingcap/tikv',
      replicas: 3,
      maxFailoverCount: 0,
      storageClassName: 'local-path',
      requests: {
        cpu: '30m',
        memory: '1900Mi',
        storage: '8Gi',
      },
      limits: {
        memory: '2Gi',
      },
      affinity: componentAffinity('tikv'),
      config: |||
        [security]
          cert-allowed-cn = ["TiDB", "SeaweedFS"]
      |||,
    },
  },
}
