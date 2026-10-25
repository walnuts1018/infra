local app = import 'app.json5';
local config = import 's3-config.libsonnet';
{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'ResourceReferenceGrant',
  metadata: {
    name: 'mcl-playground-api',
    namespace: config.seaweedRef.namespace,
  },
  spec: {
    from: [
      { group: 'seaweed.seaweedfs.com', kind: 'S3Identity', namespace: app.namespace },
      { group: 'seaweed.seaweedfs.com', kind: 'S3Credentials', namespace: app.namespace },
      { group: 'seaweed.seaweedfs.com', kind: 'S3Policy', namespace: app.namespace },
      { group: 'seaweed.seaweedfs.com', kind: 'S3PolicyBinding', namespace: app.namespace },
    ],
    to: [
      {
        group: 'seaweed.seaweedfs.com',
        kind: 'Seaweed',
        name: config.seaweedRef.name,
      },
    ],
  },
}
