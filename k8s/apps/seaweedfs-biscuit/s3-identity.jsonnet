local app = import 'app.json5';
{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'S3Identity',
  metadata: {
    name: 'cloudnative-pg-backup',
    namespace: app.namespace,
  },
  spec: {
    name: 'cloudnative-pg-backup',
    seaweedRef: {
      name: app.name,
    },
    reclaimPolicy: 'Retain',
  },
}
