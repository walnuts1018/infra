local app = import 'app.json5';
local s3 = import 's3-resources.libsonnet';
local resourceName = function(name)
  if name == 'DenyAllPolicy' then 'deny-all-policy'
  else std.strReplace(name, '_', '-');
local names = std.sort([identity.policyName for identity in s3.identities]);
[
  {
    apiVersion: 'seaweed.seaweedfs.com/v1',
    kind: 'S3Policy',
    metadata: {
      name: resourceName(name),
      namespace: app.namespace,
    },
    spec: {
      name: name,
      seaweedRef: {
        name: app.name,
      },
      policyDocument: std.manifestJson(s3.policies[name]),
      reclaimPolicy: 'Retain',
    },
  }
  for name in names
]
