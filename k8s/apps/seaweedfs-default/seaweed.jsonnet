{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'Seaweed',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    image: 'chrislusf/seaweedfs:4.07',
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
        cpu: '1',
        memory: '2Gi',
      },
    },
    // TODO: volumeTopology使いたいけど、ServiceのSelectorがバグってる気がする
    volume: {
      replicas: 3,
      requests: {
        cpu: '6m',
        memory: '256Mi',
        storage: '2Gi',
      },
      limits: {
        cpu: '1',
        memory: '2Gi',
      },
      storageClassName: 'local-path',
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
        configSecret: {
          name: (import 'external-secret-config.jsonnet').spec.target.name,
          key: 'seaweedfs_s3_config.json',
        },
      },
      requests: {
        cpu: '10m',
        memory: '90Mi',
      },
      limits: {
        cpu: '1',
        memory: '2Gi',
      },
      service: {
        type: 'ClusterIP',
      },
      config: '',
      extraArgs: ['-s3.iam.config=/etc/seaweedfs/iam.json'],
      metricsPort: 9327,
      volumes: [
        {
          name: 'filer-config-custom',
          secret: {
            secretName: (import 'external-secret-config.jsonnet').spec.target.name,
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
            secretName: 'scylla-cluster-local-client-ca',  // database namespaceから手動コピーしてるけどいい方法を考えないといけない
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
