local app = import 'app.json5';
local s3 = import 's3-resources.libsonnet';
[
  {
    apiVersion: 'seaweed.seaweedfs.com/v1',
    kind: 'Bucket',
    metadata: {
      name: bucket,
      namespace: app.namespace,
    },
    spec: {
      clusterRef: {
        name: app.name,
      },
      adoptExisting: true,
      reclaimPolicy: 'Retain',
    },
  }
  for bucket in s3.buckets
]
