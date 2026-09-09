local policy = import '../seaweedfs-default/policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'S3Policy',
  metadata: {
    name: 'cloudnative-pg-backup-access-key',
    namespace: app.namespace,
  },
  spec: {
    name: 'cloudnative-pg-backup-access-key',
    seaweedRef: {
      name: app.name,
    },
    policyDocument: std.manifestJson(policy.document([
      {
        effect: 'Allow',
        actions: ['Read', 'Write', 'List', 'Tagging'],
        buckets: ['cloudnative-pg-backup'],
      },
    ])),
    reclaimPolicy: 'Retain',
  },
}
