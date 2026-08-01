local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
local config = import 'config.libsonnet';

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

local s3Credentials = externalSecret {
  name: app.name + '-s3-credentials',
  namespace: app.namespace,
  data: [
    {
      secretKey: identity.secretKeyField,
      remoteRef: {
        key: 'seaweedfs',
        property: identity.secretKeyProperty,
      },
    }
    for identity in config.identities
  ],
  template_data: std.foldl(
    function(data, identity)
      data {
        [identity.accessKeyField]: identity.accessKey,
        [identity.secretKeyField]: '{{ .' + identity.secretKeyField + ' }}',
      },
    config.identities,
    {}
  ),
};

{
  filerConfig: filerConfig,
  s3Credentials: s3Credentials,
}
