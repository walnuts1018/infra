local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local externalSecretConfig = (import 'external-secrets.libsonnet').filerConfig;
{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'Seaweed',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    image: 'chrislusf/seaweedfs:4.41_large_disk',
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
        // local-path doesn't enforce this as a quota (it just creates a
        // hostPath dir on the node's root disk), so this mainly documents
        // the intended capacity ceiling matched by maxVolumeCounts below.
        storage: '150Gi',
      },
      limits: {
        cpu: '1',
        memory: '2Gi',
      },
      storageClassName: 'local-path',
      // The operator's default (-max=0, auto-detect) computes free slots as
      // (real free disk) MINUS the unused headroom already reserved inside
      // existing volumes below their volumeSizeLimitMB cap, summed across
      // every volume on the disk. With hundreds of partially-filled volumes
      // from other collections, that reserved headroom alone can exceed the
      // real free disk, pinning the computed max at (or near) the current
      // volume count — i.e. zero room to grow, even with the disk mostly
      // empty. This blocks new collections (like a fresh S3 bucket) from
      // ever getting their first volume ("No matching data node found").
      // Pin an explicit ceiling instead, matching the storage request above
      // (150Gi / 1024MB volumeSizeLimitMB). Current actual usage is ~96GB
      // logical (~64GB/node physical average with 001 replication) across
      // loki-chunks and cloudnative-pg-backup as the two largest, still-
      // growing collections, so this leaves roughly 2x headroom over the
      // current per-node footprint while staying well under the smallest
      // volume server's real disk size (~371GB), leaving room for other
      // workloads sharing that node's disk via local-path.
      maxVolumeCounts: 150,
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
