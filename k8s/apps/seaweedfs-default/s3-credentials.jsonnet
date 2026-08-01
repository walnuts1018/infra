local app = import 'app.json5';
local credentialsSecret = (import 'external-secret-s3-credentials.jsonnet').spec.target.name;
local s3 = import 's3-resources.libsonnet';
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
        accessKeyField: identity.name + '_accesskey',
        secretKeyField: identity.name + '_secretkey',
      },
      reclaimPolicy: 'Retain',
    },
  }
  for identity in s3.identities
]
