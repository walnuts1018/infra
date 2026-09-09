local app = import 'app.json5';
{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'Bucket',
  metadata: {
    name: 'cloudnative-pg-backup',
    namespace: app.namespace,
  },
  spec: {
    clusterRef: {
      name: app.name,
    },
    adoptExisting: true,
    objectLock: false,
    placement: {
      diskType: 'hdd',
      replication: '000',
    },
    reclaimPolicy: 'Retain',
    versioning: 'Off',
  },
}
