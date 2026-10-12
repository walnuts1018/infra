local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
local config = import 'config.libsonnet';

local externalCredentials = [
  identity
  for identity in config.identities
  if identity.external
];

local credentialSecret(identity) = externalSecret {
  name: identity.secretRef.secretName,
  namespace: identity.secretRef.namespace,
  use_suffix: false,
  spec+: {
    target+: {
      creationPolicy: 'Orphan',
    },
  },
  data: [
    {
      secretKey: 'accesskey',
      remoteRef: {
        key: 'seaweedfs',
        property: identity.accessKeyProperty,
      },
    },
    {
      secretKey: 'secretkey',
      remoteRef: {
        key: 'seaweedfs',
        property: identity.secretKeyProperty,
      },
    },
  ],
  template_data: {
    accesskey: '{{ .accesskey }}',
    secretkey: '{{ .secretkey }}',
  },
};

local filerConfig = externalSecret {
  name: app.name + '-filer-config',
  namespace: app.namespace,
  data: [
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
  externalCredentialSecrets: [credentialSecret(identity) for identity in externalCredentials],
}
