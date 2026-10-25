local policy = import '../seaweedfs-default/policy.libsonnet';
local app = import 'app.json5';
local config = import 's3-config.libsonnet';
[
  {
    apiVersion: 'seaweed.seaweedfs.com/v1',
    kind: 'S3Policy',
    metadata: {
      name: identity.policyName,
      namespace: app.namespace,
    },
    spec: {
      name: identity.policyName,
      seaweedRef: config.seaweedRef,
      policyDocument: std.manifestJson(policy.document(identity.permissions)),
      reclaimPolicy: 'Retain',
    },
  }
  for identity in config.identities
]
