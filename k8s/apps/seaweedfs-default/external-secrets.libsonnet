local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
local config = import 'config.libsonnet';

// Identities that aren't owned by an in-cluster app (no ExternalSecret of
// their own to adopt credentials into) get a Secret created here instead,
// pulling the pre-existing access/secret key from 1Password so the
// S3Credentials operator has something non-empty to adopt.
local selfManagedIdentityNames = ['terraform', 'mac_hatena'];

local credentialSecret(identity) = externalSecret {
  name: app.name + '-' + identity.resourceName + '-credentials',
  namespace: app.namespace,
  data: [
    {
      secretKey: 'secretkey',
      remoteRef: {
        key: 'seaweedfs',
        property: identity.secretKeyProperty,
      },
    },
  ],
  template_data: {
    accesskey: identity.accessKey,
    secretkey: '{{ .secretkey }}',
  },
};

local selfManagedCredentials = [
  { identity: identity, secret: credentialSecret(identity) }
  for identity in config.identities
  if std.member(selfManagedIdentityNames, identity.name)
];

local filerConfig = externalSecret {
  name: app.name + '-filer-config',
  namespace: app.namespace,
  data: [
    {
      secretKey: 'scylladb_password',
      remoteRef: {
        key: 'scylladb',
        property: 'seaweedfs',
      },
    },
    {
      secretKey: 'postgres_seaweedfs_password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'seaweedfs',
      },
    },
    {
      secretKey: config.stsSigningKeyProperty,
      remoteRef: {
        key: 'seaweedfs',
        property: config.stsSigningKeyProperty,
      },
    },
  ],
  template_data: {
    'filer.toml': (importstr '_configs/filer.toml'),
    'iam.json': std.manifestJson(config.iam),
  },
};

{
  filerConfig: filerConfig,
  selfManagedCredentialSecrets: [c.secret for c in selfManagedCredentials],
  selfManagedCredentialTargets: {
    [c.identity.name]: {
      namespace: app.namespace,
      secretName: c.secret.metadata.name,
      accessKeyField: 'accesskey',
      secretKeyField: 'secretkey',
    }
    for c in selfManagedCredentials
  },
}
