{
  apiVersion: 'minio.min.io/v2',
  kind: 'Tenant',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    // env: [
    //   {
    //     name: 'MINIO_IDENTITY_OPENID_CONFIG_URL',
    //     value: 'https://auth.walnuts.dev/.well-known/openid-configuration',
    //   },
    //   {
    //     name: 'MINIO_IDENTITY_OPENID_CLIENT_ID',
    //     value: 'OPENID CLIENT ID',
    //   },
    //   {
    //     name: 'MINIO_IDENTITY_OPENID_CLIENT_SECRET',
    //     value: 'OPENID CLIENT SECRET',
    //   },
    //   {
    //     name: 'MINIO_IDENTITY_OPENID_SCOPES',
    //     value: 'openid,profile,email',
    //   },
    //   {
    //     name: 'MINIO_IDENTITY_OPENID_CLAIM_NAME',
    //     value: 'https://min.io/policy',
    //   },
    // ],
  },
}
