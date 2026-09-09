local app = import 'app.json5';
{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'S3PolicyBinding',
  metadata: {
    name: 'cloudnative-pg-backup',
    namespace: app.namespace,
  },
  spec: {
    seaweedRef: {
      name: app.name,
    },
    policyRef: {
      name: 'cloudnative-pg-backup-access-key',
    },
    subjects: [
      {
        kind: 'S3Identity',
        name: 'cloudnative-pg-backup',
      },
    ],
    reclaimPolicy: 'Retain',
  },
}
