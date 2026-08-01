local app = import 'app.json5';
local config = import 'config.libsonnet';
[
  {
    apiVersion: 'seaweed.seaweedfs.com/v1',
    kind: 'S3Identity',
    metadata: {
      name: identity.resourceName,
      namespace: app.namespace,
    },
    spec: {
      name: identity.name,
      seaweedRef: {
        name: app.name,
      },
      reclaimPolicy: 'Retain',
    },
  }
  for identity in config.identities
]
