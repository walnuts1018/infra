// Loads _configs/desired-state.json, validates it for internal consistency,
// and derives the values the various *.jsonnet manifests need
// (bucket list, S3 identities/policies, IAM+STS config for the filer).
//
// See policy.libsonnet / sts.libsonnet for how policy documents and STS
// config are built from the desired-state shorthand.

local desired = import '_configs/desired-state.json';
local policy = import 'policy.libsonnet';
local sts = import 'sts.libsonnet';

local unique(values) = std.length(std.uniq(std.sort(values))) == std.length(values);

local identities = [
  identity {
    resourceName: std.strReplace(identity.name, '_', '-'),
    policyName: std.strReplace(identity.name, '_', '-') + '-access-key',
    policyDocument: policy.document(identity.permissions),
    accessKeyField: identity.accessKey + '_accesskey',
    secretKeyField: identity.accessKey + '_secretkey',
  }
  for identity in desired.accessKeyIdentities
];

local bucketNames = [bucket.name for bucket in desired.buckets];
local identityNames = [identity.name for identity in identities];
local policyNames = [p.name for p in desired.sts.policies];
local roleNames = [role.name for role in desired.sts.roles];
local providerNames = [provider.name for provider in desired.sts.providers];

local referencedBuckets = std.flattenArrays(
  [statement.buckets for policy_ in desired.sts.policies for statement in policy_.statements if std.objectHas(statement, 'buckets')]
  + [permission.buckets for identity in desired.accessKeyIdentities for permission in identity.permissions if std.objectHas(permission, 'buckets')]
);
local referencedRoles = std.flattenArrays([
  [provider.defaultRole] + [mapping.role for mapping in provider.mappings]
  for provider in desired.sts.providers
]);
local referencedProviders = [role.provider for role in desired.sts.roles if std.objectHas(role, 'provider')];
local attachedPolicies = std.flattenArrays([role.policies for role in desired.sts.roles]);

assert unique(bucketNames) : 'bucket names must be unique';
assert unique(identityNames) : 'access-key identity names must be unique';
assert unique([identity.resourceName for identity in identities]) : 'access-key identity resource names must be unique after normalization';
assert unique([identity.policyName for identity in identities]) : 'access-key identity policy names must be unique';
assert unique([identity.accessKey for identity in identities]) : 'access-key identity access keys must be unique';
assert unique(policyNames) : 'STS policy names must be unique';
assert unique(roleNames) : 'STS role names must be unique';
assert unique(providerNames) : 'OIDC provider names must be unique';
assert std.length(std.setInter([identity.policyName for identity in identities], policyNames)) == 0
       : 'access-key and STS policy names must not overlap';
assert std.all([std.member(bucketNames, bucket) for bucket in referencedBuckets])
       : 'identity and STS policies must only reference declared buckets';
assert std.all([std.member(roleNames, role) for role in referencedRoles])
       : 'OIDC mappings must only reference declared roles';
assert std.all([std.member(providerNames, provider) for provider in referencedProviders])
       : 'STS roles must only reference declared OIDC providers';
assert std.all([std.member(policyNames + ['AmazonS3FullAccess'], p) for p in attachedPolicies])
       : 'STS roles must only attach declared or built-in policies';

{
  buckets: [desired.bucketDefaults + bucket for bucket in desired.buckets],
  identities: identities,
  iam: sts.build(desired.sts),
  stsSigningKeyProperty: desired.sts.signingKeyProperty,
}
