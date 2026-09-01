local app = import 'app.json5';
local config = import 'config.libsonnet';


[
  {
    apiVersion: 'seaweed.seaweedfs.com/v1',
    kind: 'S3Credentials',
    metadata: {
      name: identity.resourceName,
      namespace: app.namespace,
    },
    spec: {
      seaweedRef: {
        name: app.name,
      },
      identityRef: {
        name: identity.resourceName,
      },
      secretRef: {
        name: identity.secretRef.secretName,
        namespace: identity.secretRef.namespace,
        accessKeyField: identity.secretRef.accessKeyField,
        secretKeyField: identity.secretRef.secretKeyField,
      },
      reclaimPolicy: 'Retain',
    },
  }
  for identity in config.identities
]
