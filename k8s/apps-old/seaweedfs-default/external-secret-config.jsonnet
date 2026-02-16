(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-filer-config',
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'scylladb_password',
      remoteRef: {
        key: 'scylladb',
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
    {
      secretKey: 'terraform_secretkey',
      remoteRef: {
        key: 'seaweedfs',
        property: 'terraform_secretkey',
      },
    },
    {
      secretKey: 'misskey_secretkey',
      remoteRef: {
        key: 'seaweedfs',
        property: 'misskey_secretkey',
      },
    },
    {
      secretKey: 'oekaki_dengon_game_secretkey',
      remoteRef: {
        key: 'seaweedfs',
        property: 'oekaki_dengon_game_secretkey',
      },
    },
  ],
  template_data: {
    'filer.toml': (importstr '_configs/filer.toml'),
    'iam.json': (importstr '_configs/iam.json'),
    'seaweedfs_s3_config.json': (importstr '_configs/seaweedfs_s3_config.json'),
  },
}
