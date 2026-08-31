local labels = import '../../components/labels.libsonnet';
local storage = import '../../components/storage.libsonnet';
local app = import 'app.json5';
local externalSecretConfig = (import 'external-secrets.libsonnet').filerConfig;
{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'Seaweed',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    image: 'chrislusf/seaweedfs:4.44_large_disk_full',
    master: {
      replicas: 3,
      volumeSizeLimitMB: 1024,
      defaultReplication: '001',
      env: [
        {
          name: 'WEED_MASTER_VOLUME_GROWTH_COPY_1',
          value: '1',
        },
        {
          name: 'WEED_MASTER_VOLUME_GROWTH_COPY_2',
          value: '1',
        },
        {
          name: 'WEED_MASTER_VOLUME_GROWTH_COPY_3',
          value: '1',
        },
        {
          name: 'WEED_MASTER_VOLUME_GROWTH_COPY_OTHER',
          value: '1',
        },
      ],
      affinity: {
        nodeAffinity: storage.avoidSlowNodeAffinity.nodeAffinity,
        podAntiAffinity: {
          preferredDuringSchedulingIgnoredDuringExecution: [
            {
              weight: 100,
              podAffinityTerm: {
                labelSelector: {
                  matchLabels: {
                    'app.kubernetes.io/component': 'master',
                    'app.kubernetes.io/instance': $.metadata.name,
                  },
                },
                topologyKey: 'kubernetes.io/hostname',
              },
            },
          ],
        },
      },
      metricsPort: 9327,
      requests: {
        cpu: '6m',
        memory: '36Mi',
      },
      limits: {
        memory: '2Gi',
      },
    },
    // TODO: volumeTopology使いたいけど、ServiceのSelectorがバグってる気がする
    volume: {
      replicas: 3,
      requests: {
        cpu: '6m',
        memory: '512Mi',
        storage: '300Gi',
      },
      limits: {
        memory: '2Gi',
      },
      storageClassName: 'local-path',
      // PVのサイズとは関係なく、maxVolumeCounts×volumeSizeLimitMBが1ノードあたりの最大ストレージ容量になる
      // 0にすると自動設定される、が、実際にはまだストレージが空いているのに「No matching data node found」が起こることがあったので手動調整することにする
      // 1000という数字にはあまり根拠がない
      maxVolumeCounts: 1000,
      // local-pathはPVCの容量上限が機能しないので、Nodeのストレージを埋めすぎないように設定しておく
      minFreeSpacePercent: 10,
      metricsPort: 9327,
      affinity: {
        local labels = {
          'app.kubernetes.io/component': 'volume',
          'app.kubernetes.io/instance': $.metadata.name,
        },
        nodeAffinity: storage.avoidSlowNodeAffinity.nodeAffinity,
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
        cpu: '60m',
        memory: '512Mi',
      },
      limits: {
        memory: '2Gi',
      },
      service: {
        type: 'ClusterIP',
      },
      config: '',
      extraArgs: [
        '-s3.iam.config=/etc/seaweedfs/iam.json',
        '-s3.domainName=seaweedfs.local.walnuts.dev',
      ],
      affinity: {
        nodeAffinity: storage.avoidSlowNodeAffinity.nodeAffinity,
        podAntiAffinity: {
          preferredDuringSchedulingIgnoredDuringExecution: [
            {
              weight: 100,
              podAffinityTerm: {
                labelSelector: {
                  matchLabels: {
                    'app.kubernetes.io/component': 'filer',
                    'app.kubernetes.io/instance': $.metadata.name,
                  },
                },
                topologyKey: 'kubernetes.io/hostname',
              },
            },
          ],
        },
      },
      metricsPort: 9327,
      volumes: [
        {
          name: 'filer-config-custom',
          secret: {
            secretName: externalSecretConfig.spec.target.name,
          },
        },
        {
          name: 'tikv-client-cert',
          secret: {
            secretName: (import 'tikv-client-certificate.jsonnet').spec.secretName,
            items: [
              {
                key: 'ca.crt',
                path: 'ca.crt',
              },
              {
                key: 'tls.crt',
                path: 'tls.crt',
              },
              {
                key: 'tls.key',
                path: 'tls.key',
              },
            ],
          },
        },
      ],
      volumeMounts: [
        {
          mountPath: '/etc/seaweedfs',
          name: 'filer-config-custom',
          readOnly: true,
        },
        {
          mountPath: '/etc/seaweedfs/tikv-client',
          name: 'tikv-client-cert',
          readOnly: true,
        },
      ],
    },
  },
}
