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

{
  filerConfig: filerConfig,
}
