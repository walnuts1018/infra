local app = import 'app.json5';
local secret = app.name + '-runtime';
local fields = [
  ['DATABASE_URL', 'database_url'],
  ['POSTGRES_USER', 'database_user'],
  ['POSTGRES_PASSWORD', 'database_password'],
  ['POSTGRES_DB', 'database_name'],
  ['RABBITMQ_URL', 'rabbitmq_url'],
  ['S3_ACCESS_KEY_ID', 's3_access_key_id'],
  ['S3_SECRET_ACCESS_KEY', 's3_secret_access_key'],
  ['S3_ACCESS_KEY', 's3_access_key_id'],
  ['S3_SECRET_KEY', 's3_secret_access_key'],
  ['AWS_ACCESS_KEY_ID', 's3_access_key_id'],
  ['AWS_SECRET_ACCESS_KEY', 's3_secret_access_key'],
  ['OIDC_CLIENT_ID', 'oidc_client_id'],
  ['OIDC_CLIENT_SECRET', 'oidc_client_secret'],
];
{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: secret,
    namespace: app.namespace,
  },
  spec: {
    refreshInterval: '1h',
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    target: {
      name: secret,
      creationPolicy: 'Owner',
      deletionPolicy: 'Retain',
    },
    data: [
      {
        secretKey: item[0],
        remoteRef: {
          key: app.name,
          property: item[1],
        },
      }
      for item in fields
    ],
  },
}
