local app = import 'app.json5';
local s3 = import 's3-resources.libsonnet';
[
  {
    apiVersion: 'seaweed.seaweedfs.com/v1',
    kind: 'S3PolicyBinding',
    metadata: {
      name: identity.resourceName,
      namespace: app.namespace,
    },
    spec: {
      seaweedRef: {
        name: app.name,
      },
      policyRef: {
        name: identity.policyName,
      },
      subjects: [
        {
          kind: 'S3Identity',
          name: identity.resourceName,
        },
      ],
      reclaimPolicy: 'Retain',
    },
  }
  for identity in s3.identities
]
