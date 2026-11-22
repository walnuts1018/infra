local storage = import '../../components/storage.libsonnet';
local app = import 'app.json5';
local tikvImage = 'pingcap/tikv:v8.5.7';
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
    version: std.split(tikvImage, ':')[1],
    timezone: 'Asia/Tokyo',
    pvReclaimPolicy: 'Retain',
    enableDynamicConfiguration: true,
    configUpdateStrategy: 'RollingUpdate',
    tlsCluster: {
      enabled: true,
    },
    discovery: {},
    helper: {
      image: 'alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf',
    },
    pd: {
      baseImage: 'pingcap/pd',
      replicas: 3,
      maxFailoverCount: 0,
      storageClassName: 'local-path',
      requests: {
        cpu: '45m',
        memory: '110Mi',
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
      baseImage: std.split(tikvImage, ':')[0],
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
      // TiKVは起動時にDWARFデバッグ情報を読み込み、プロセス終了まで保持している
      // v8.5.7で2026/11/22に計測したとき、デバッグ情報のために確保されたメモリがヒーププロファイルの上位5件だけで約1.5GiBで、約0.5GiBのSwapも使っていた
      // 流石に使いすぎなのでパニック時の情報欠損を許容して、initContainerでデバッグ情報を除去することにする
      initContainers: [
        {
          name: 'strip-tikv-debug',
          image: tikvImage,
          command: ['/bin/sh', '-ec'],
          args: [
            'cp /tikv-server /opt/tikv-runtime/tikv-server && strip --strip-debug /opt/tikv-runtime/tikv-server && test -x /opt/tikv-runtime/tikv-server',
          ],
          securityContext: {
            runAsUser: 0,
            allowPrivilegeEscalation: false,
            capabilities: { drop: ['ALL'] },
          },
          resources: {
            requests: {
              cpu: '25m',
              memory: '128Mi',
            },
            limits: {
              memory: '1Gi',
            },
          },
          volumeMounts: [
            {
              name: 'tikv-runtime',
              mountPath: '/opt/tikv-runtime',
            },
          ],
        },
      ],
      additionalVolumes: [
        {
          name: 'tikv-runtime',
          emptyDir: {
            sizeLimit: '1Gi',
          },
        },
      ],
      additionalVolumeMounts: [
        {
          name: 'tikv-runtime',
          mountPath: '/tikv-server',
          subPath: 'tikv-server',
          readOnly: true,
        },
      ],
      config: |||
        [security]
          cert-allowed-cn = ["TiDB", "SeaweedFS"]
      |||,
    },
  },
}
