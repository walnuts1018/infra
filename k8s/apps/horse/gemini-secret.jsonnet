{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: 'horse-ai',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    refreshInterval: '1h',
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    target: { name: 'horse-ai' },
    data: [
      {
        secretKey: 'GEMINI_FREE_API_KEY',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-free-api-key',
        },
      },
      {
        secretKey: 'GEMINI_PAID_API_KEY',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-paid-api-key',
        },
      },
      {
        secretKey: 'GEMINI_FREE_PROJECT_ID',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-free-project-id',
        },
      },
      {
        secretKey: 'GEMINI_PAID_PROJECT_ID',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-paid-project-id',
        },
      },
    ],
  },
}
