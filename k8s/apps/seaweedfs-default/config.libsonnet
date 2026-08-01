local desired = import '_configs/desired-state.json';

local unique(values) = std.length(std.uniq(std.sort(values))) == std.length(values);
local roleArn(name) = 'arn:aws:iam::role/' + name;
local resourceArn(resource) =
  if resource == '*' || std.startsWith(resource, 'arn:') then resource
  else 'arn:aws:s3:::' + resource;
local bucketResources(buckets) =
  [resourceArn(bucket) for bucket in buckets]
  + [resourceArn(bucket + '/*') for bucket in buckets];
local actionAliases = {
  Admin: ['s3:*'],
  List: ['s3:List*'],
  Read: ['s3:Get*'],
  Tagging: ['s3:*Tagging'],
  Write: ['s3:Put*', 's3:Delete*', 's3:AbortMultipartUpload'],
};
local actions(statement) = std.flattenArrays([
  if std.objectHas(actionAliases, action) then actionAliases[action] else [action]
  for action in statement.actions
]);
local resources(statement) =
  if std.objectHas(statement, 'buckets') then bucketResources(statement.buckets)
  else [resourceArn(resource) for resource in statement.resources];
local policyDocument(statements) = {
  Version: '2012-10-17',
  Statement: [
    {
      Effect: statement.effect,
      Action: actions(statement),
      Resource: resources(statement),
    }
    for statement in statements
  ],
};
local providerByName(name) = std.filter(
  function(provider) provider.name == name,
  desired.sts.providers,
)[0];
local trustPolicy(role) = {
  Version: '2012-10-17',
  Statement: [
    {
      Effect: 'Allow',
      Principal: {
        Federated: '*',
      },
      Action: ['sts:AssumeRoleWithWebIdentity'],
    } + if !std.objectHas(role, 'provider') then {} else {
      Condition: {
        StringEquals: {
          'oidc:iss': providerByName(role.provider).issuer,
        },
      } + if !std.objectHas(role, 'subjectPatterns') then {} else {
        StringLike: {
          'oidc:sub': role.subjectPatterns,
        },
      },
    },
  ],
};
local iamProvider(provider) = {
  name: provider.name,
  type: provider.type,
  enabled: true,
  config: {
    issuer: provider.issuer,
    clientId: provider.clientId,
    jwksUri: provider.jwksUri,
    [if std.objectHas(provider, 'tlsCaCert') then 'tlsCaCert']: provider.tlsCaCert,
    roleMapping: {
      rules: [
        {
          claim: mapping.claim,
          value: mapping.value,
          role: roleArn(mapping.role),
        }
        for mapping in provider.mappings
      ],
      defaultRole: roleArn(provider.defaultRole),
    },
  },
};
local bucketNames = [bucket.name for bucket in desired.buckets];
local identityNames = [identity.name for identity in desired.accessKeyIdentities];
local identityResourceNames = [std.strReplace(identity.name, '_', '-') for identity in desired.accessKeyIdentities];
local identityPolicyNames = [resourceName + '-access-key' for resourceName in identityResourceNames];
local accessKeys = [identity.accessKey for identity in desired.accessKeyIdentities];
local policyNames = [policy.name for policy in desired.sts.policies];
local roleNames = [role.name for role in desired.sts.roles];
local providerNames = [provider.name for provider in desired.sts.providers];
local stsReferencedBuckets = std.flattenArrays([
  if std.objectHas(statement, 'buckets') then statement.buckets else []
  for policy in desired.sts.policies
  for statement in policy.statements
]);
local identityReferencedBuckets = std.flattenArrays([
  if std.objectHas(permission, 'buckets') then permission.buckets else []
  for identity in desired.accessKeyIdentities
  for permission in identity.permissions
]);
local mappedRoles = std.flattenArrays([
  [provider.defaultRole] + [mapping.role for mapping in provider.mappings]
  for provider in desired.sts.providers
]);
local referencedProviders = [role.provider for role in desired.sts.roles if std.objectHas(role, 'provider')];
local attachedPolicies = std.flattenArrays([role.policies for role in desired.sts.roles]);

assert unique(bucketNames) : 'bucket names must be unique';
assert unique(identityNames) : 'access-key identity names must be unique';
assert unique(identityResourceNames) : 'access-key identity resource names must be unique after normalization';
assert unique(identityPolicyNames) : 'access-key identity policy names must be unique';
assert unique(accessKeys) : 'access-key identity access keys must be unique';
assert unique(policyNames) : 'STS policy names must be unique';
assert unique(roleNames) : 'STS role names must be unique';
assert unique(providerNames) : 'OIDC provider names must be unique';
assert std.all([std.member(bucketNames, bucket) for bucket in stsReferencedBuckets + identityReferencedBuckets])
       : 'identity and STS policies must only reference declared buckets';
assert std.length(std.setInter(identityPolicyNames, policyNames)) == 0
       : 'access-key and STS policy names must not overlap';
assert std.all([std.member(roleNames, role) for role in mappedRoles])
       : 'OIDC mappings must only reference declared roles';
assert std.all([std.member(providerNames, provider) for provider in referencedProviders])
       : 'STS roles must only reference declared OIDC providers';
assert std.all([
  std.member(policyNames + ['AmazonS3FullAccess'], policy)
  for policy in attachedPolicies
]) : 'STS roles must only attach declared or built-in policies';
{
  buckets: [desired.bucketDefaults + bucket for bucket in desired.buckets],
  identities: [
    identity {
      resourceName: std.strReplace(identity.name, '_', '-'),
      policyName: std.strReplace(identity.name, '_', '-') + '-access-key',
      policyDocument: policyDocument(identity.permissions),
      accessKeyField: identity.accessKey + '_accesskey',
      secretKeyField: identity.accessKey + '_secretkey',
    }
    for identity in desired.accessKeyIdentities
  ],
  iam: {
    sts: {
      tokenDuration: desired.sts.tokenDuration,
      maxSessionLength: desired.sts.maxSessionLength,
      issuer: desired.sts.issuer,
      signingKey: '{{ .' + desired.sts.signingKeyProperty + ' | b64enc }}',
    },
    providers: [iamProvider(provider) for provider in desired.sts.providers],
    policies: [
      {
        name: policy.name,
        content: std.manifestJson(policyDocument(policy.statements)),
      }
      for policy in desired.sts.policies
    ],
    roles: [
      {
        roleName: role.name,
        roleArn: roleArn(role.name),
        attachedPolicies: role.policies,
        trustPolicy: trustPolicy(role),
      }
      for role in desired.sts.roles
    ],
  },
  stsSigningKeyProperty: desired.sts.signingKeyProperty,
}
