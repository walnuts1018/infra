local app = import 'app.json5';
local config = import 'config.libsonnet';
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
      seaweedRef: {
        name: app.name,
      },
      policyDocument: std.manifestJson(identity.policyDocument),
      reclaimPolicy: 'Retain',
    },
  }
  for identity in config.identities
]
