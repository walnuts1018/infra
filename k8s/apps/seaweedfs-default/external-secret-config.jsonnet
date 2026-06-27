local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
local filer = importstr '_configs/filer.toml';
local iam = importstr '_configs/iam.json';
local seaweedfsS3Config = importstr '_configs/seaweedfs_s3_config.json';
(externalSecret) {
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
    {
      secretKey: 'stalwart_secretkey',
      remoteRef: {
        key: 'seaweedfs',
        property: 'stalwart_secretkey',
      },
    },
  ],
  template_data: {
    'filer.toml': (filer),
    'iam.json': (iam),
    'seaweedfs_s3_config.json': (seaweedfsS3Config),
  },
}
