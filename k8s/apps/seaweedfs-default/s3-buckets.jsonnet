local app = import 'app.json5';
local config = import 'config.libsonnet';
[
  {
    apiVersion: 'seaweed.seaweedfs.com/v1',
    kind: 'Bucket',
    metadata: {
      name: bucket.name,
      namespace: app.namespace,
    },
    spec: {
      clusterRef: {
        name: app.name,
      },
      adoptExisting: bucket.adoptExisting,
      objectLock: bucket.objectLock,
      reclaimPolicy: bucket.reclaimPolicy,
      versioning: bucket.versioning,
    } + if std.objectHas(bucket, 'placement') then {
      placement: bucket.placement,
    } else {},
  }
  for bucket in config.buckets
]
