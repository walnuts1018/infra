local app = import 'app.json5';
local config = import 's3-config.libsonnet';
[
  {
    apiVersion: 'seaweed.seaweedfs.com/v1',
    kind: 'S3Credentials',
    metadata: {
      name: identity.resourceName,
      namespace: app.namespace,
    },
    spec: {
      seaweedRef: config.seaweedRef,
      identityRef: { name: identity.resourceName },
      secretRef: {
        name: identity.secretName,
        accessKeyField: identity.accessKeyField,
        secretKeyField: identity.secretKeyField,
      },
      reclaimPolicy: 'Retain',
    },
  }
  for identity in config.identities
]
