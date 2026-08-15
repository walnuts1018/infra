// Builds SeaweedFS STS config (OIDC providers, trust policies, roles) from
// the desired-state.json `sts` section.

local policy = import 'policy.libsonnet';

local providerByName(providers, name) = std.filter(
  function(provider) provider.name == name,
  providers,
)[0];

local trustPolicy(providers, role) = {
  Version: '2012-10-17',
  Statement: [
    {
      Effect: 'Allow',
      Principal: { Federated: '*' },
      Action: ['sts:AssumeRoleWithWebIdentity'],
    } + if !std.objectHas(role, 'provider') then {} else {
      Condition: {
        StringEquals: {
          'oidc:iss': providerByName(providers, role.provider).issuer,
        },
      } + if !std.objectHas(role, 'subjectPatterns') then {} else {
        StringLike: {
          'oidc:sub': role.subjectPatterns,
        },
      },
    },
  ],
};

local provider(p) = {
  name: p.name,
  type: p.type,
  enabled: true,
  config: {
    issuer: p.issuer,
    clientId: p.clientId,
    jwksUri: p.jwksUri,
    [if std.objectHas(p, 'tlsCaCert') then 'tlsCaCert']: p.tlsCaCert,
    roleMapping: {
      rules: [
        { claim: mapping.claim, value: mapping.value, role: policy.roleArn(mapping.role) }
        for mapping in p.mappings
      ],
      defaultRole: policy.roleArn(p.defaultRole),
    },
  },
};

local role(providers, r) = {
  roleName: r.name,
  roleArn: policy.roleArn(r.name),
  attachedPolicies: r.policies,
  trustPolicy: trustPolicy(providers, r),
};

{
  build(sts):: {
    tokenDuration: sts.tokenDuration,
    maxSessionLength: sts.maxSessionLength,
    issuer: sts.issuer,
    signingKey: '{{ .' + sts.signingKeyProperty + ' | b64enc }}',
    providers: [provider(p) for p in sts.providers],
    policies: [
      { name: p.name, document: policy.document(p.statements) }
      for p in sts.policies
    ],
    roles: [role(sts.providers, r) for r in sts.roles],
  },
}
