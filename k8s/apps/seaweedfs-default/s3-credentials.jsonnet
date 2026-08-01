local app = import 'app.json5';
local config = import 'config.libsonnet';
local credentialsSecret = (import 'external-secrets.libsonnet').s3Credentials.spec.target.name;
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
        name: credentialsSecret,
        accessKeyField: identity.accessKeyField,
        secretKeyField: identity.secretKeyField,
      },
      reclaimPolicy: 'Retain',
    },
  }
  for identity in config.identities
]
