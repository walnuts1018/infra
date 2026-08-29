local labels = import '../../components/labels.libsonnet';
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
    image: 'chrislusf/seaweedfs:4.44_large_disk',
    master: {
      replicas: 3,
      volumeSizeLimitMB: 1024,
      defaultReplication: '001',
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
        memory: '756Mi',
        storage: '300Gi',
      },
      limits: {
        memory: '2Gi',
      },
      storageClassName: 'local-path',
      // PVのサイズとは関係なく、maxVolumeCounts×volumeSizeLimitMBが1ノードあたりの最大ストレージ容量になる
      // 0にすると自動設定される、が、実際にはまだストレージが空いているのに「No matching data node found」が起こることがあったので手動調整することにする
      // 今の感じだと、1ボリュームあたり平均144MB程度であり、1ノードあたりのボリューム数は平均223程度だったので、一旦300にしてみる。
      maxVolumeCounts: 300,
      metricsPort: 9327,
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
        cpu: '10m',
        memory: '218Mi',
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
      metricsPort: 9327,
      volumes: [
        {
          name: 'filer-config-custom',
          secret: {
            secretName: externalSecretConfig.spec.target.name,
          },
        },
        {
          name: 'scylla-db-ca-cert',
          configMap: {
            name: (import 'configmap-scylladb-ca.jsonnet').metadata.name,
            items: [
              {
                key: 'ca.crt',
                path: 'ca.crt',
              },
            ],
          },
        },
        {
          name: 'scylla-db-client-cert',
          secret: {
            secretName: 'scylla-cluster-local-client-ca',  // TODO: database namespaceから手動コピーしてるけどいい方法を考えないといけない
            items: [
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
          mountPath: '/etc/seaweedfs/scylladb-ca',
          name: 'scylla-db-ca-cert',
          readOnly: true,
        },
        {
          mountPath: '/etc/seaweedfs/scylladb-client',
          name: 'scylla-db-client-cert',
          readOnly: true,
        },
      ],
    },
  },
}
