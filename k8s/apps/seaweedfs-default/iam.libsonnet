local s3 = import 's3-resources.libsonnet';

local kubernetesIssuer = 'https://192.168.0.17:16443';
local roleArn = function(name) 'arn:aws:iam::role/' + name;
local webIdentityTrust = function(condition=null) {
  Version: '2012-10-17',
  Statement: [
    {
      Effect: 'Allow',
      Principal: {
        Federated: '*',
      },
      Action: ['sts:AssumeRoleWithWebIdentity'],
    } + if condition == null then {} else { Condition: condition },
  ],
};
local role = function(name, policies, condition=null) {
  roleName: name,
  roleArn: roleArn(name),
  attachedPolicies: policies,
  trustPolicy: webIdentityTrust(condition),
};
local kubernetesRoleMappings = [
  { serviceAccount: 'loki:loki', roleName: 'loki' },
  { serviceAccount: 'ipu:ipu', roleName: 'ipu' },
  { serviceAccount: 'picca-ai-prototype:picca-ai-prototype-gateway', roleName: 'picca-ai-prototype-gateway' },
  { serviceAccount: 'picca-ai-prototype:picca-ai-prototype-debug-web', roleName: 'picca-ai-prototype-debug-web' },
  { serviceAccount: 'misskey:misskey-postgresql', roleName: 'cloudnative-pg-backup' },
  { serviceAccount: 'databases:postgresql-default', roleName: 'cloudnative-pg-backup' },
  { serviceAccount: 'tempo:tempo', roleName: 'tempo' },
  { serviceAccount: 'pyroscope:pyroscope', roleName: 'pyroscope' },
  { serviceAccount: 'netbox:netbox', roleName: 'netbox' },
  { serviceAccount: 'stalwart:stalwart', roleName: 'stalwart' },
];
local kubernetesTrustCondition = {
  StringEquals: {
    'oidc:iss': kubernetesIssuer,
  },
};
{
  sts: {
    tokenDuration: '1h',
    maxSessionLength: '12h',
    issuer: 'seaweedfs-sts',
    signingKey: '{{ .sts_signing_key | b64enc }}',
  },
  providers: [
    {
      name: 'k8s',
      type: 'oidc',
      enabled: true,
      config: {
        issuer: kubernetesIssuer,
        clientId: 'sts.seaweedfs.com',
        jwksUri: 'https://kubernetes.default.svc/openid/v1/jwks',
        tlsCaCert: '/var/run/secrets/kubernetes.io/serviceaccount/ca.crt',
        roleMapping: {
          rules: [
            {
              claim: 'sub',
              value: 'system:serviceaccount:' + mapping.serviceAccount,
              role: roleArn(mapping.roleName),
            }
            for mapping in kubernetesRoleMappings
          ],
          defaultRole: roleArn('S3DenyAllRole'),
        },
      },
    },
    {
      name: 'terraform_cloud',
      type: 'oidc',
      enabled: true,
      config: {
        issuer: 'https://app.terraform.io',
        clientId: 'aws.workload.identity',
        jwksUri: 'https://app.terraform.io/.well-known/jwks',
        roleMapping: {
          rules: [{
            claim: 'aud',
            value: 'aws.workload.identity',
            role: roleArn('TerraformCloud'),
          }],
          defaultRole: roleArn('S3DenyAllRole'),
        },
      },
    },
  ],
  policies: [
    {
      name: name,
      document: s3.policies[name],
    }
    for name in s3.stsPolicyNames
  ],
  roles: [
    role('S3DenyAllRole', ['DenyAllPolicy']),
    role('TerraformCloud', ['AmazonS3FullAccess'], {
      StringEquals: {
        'oidc:iss': 'https://app.terraform.io',
      },
      StringLike: {
        'oidc:sub': ['organization:walnuts-dev:project:*:workspace:*:run_phase:*'],
      },
    }),
  ] + [
    role(name, [name], kubernetesTrustCondition)
    for name in [
      'loki',
      'ipu',
      'cloudnative-pg-backup',
      'picca-ai-prototype-gateway',
      'picca-ai-prototype-debug-web',
      'tempo',
      'pyroscope',
      'netbox',
      'stalwart',
    ]
  ],
}
