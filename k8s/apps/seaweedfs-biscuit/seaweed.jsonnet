local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'Seaweed',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    image: 'chrislusf/seaweedfs:4.45_large_disk_full',
    master: {
      replicas: 1,
      volumeSizeLimitMB: 1024,
      defaultReplication: '000',
      persistence: {
        enabled: true,
        storageClassName: 'topolvm-hdd',
        resources: {
          requests: {
            storage: '10Gi',
          },
        },
      },
      requests: {
        cpu: '10m',
        memory: '64Mi',
      },
      limits: {
        memory: '512Mi',
      },
    },
    volume: {
      replicas: 1,
      requests: {
        cpu: '10m',
        memory: '256Mi',
        storage: '800Gi',
      },
      limits: {
        memory: '2Gi',
      },
      storageClassName: 'topolvm-hdd',
      maxVolumeCounts: 1000,
      minFreeSpacePercent: 10,
    },
    filer: {
      replicas: 1,
      persistence: {
        enabled: true,
        storageClassName: 'topolvm-hdd',
        resources: {
          requests: {
            storage: '20Gi',
          },
        },
      },
      config: |||
        [leveldb2]
        enabled = true
        dir = "/data/filerldb2"
      |||,
      iam: true,
      extraArgs: [
        '-iam',
        '-s3.iam.readOnly=false',
      ],
      requests: {
        cpu: '30m',
        memory: '256Mi',
      },
      limits: {
        memory: '1Gi',
      },
    },
    s3: {
      replicas: 1,
    },
  },
}
