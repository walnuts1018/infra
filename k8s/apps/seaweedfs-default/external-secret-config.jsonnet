local app = import 'app.json5';
local iam = import 'iam.libsonnet';
(import '../../components/external-secret.libsonnet') {
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
      secretKey: 'sts_signing_key',
      remoteRef: {
        key: 'seaweedfs',
        property: 'sts_signing_key',
      },
    },
  ],
  template_data: {
    'filer.toml': (importstr '_configs/filer.toml'),
    'iam.json': std.manifestJson(iam),
  },
}
