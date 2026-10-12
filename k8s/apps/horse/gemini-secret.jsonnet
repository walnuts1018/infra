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
          optional: true,
        },
      },
      {
        secretKey: 'GEMINI_PAID_API_KEY',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-paid-api-key',
          optional: true,
        },
      },
      {
        secretKey: 'GEMINI_FREE_PROJECT_ID',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-free-project-id',
          optional: true,
        },
      },
      {
        secretKey: 'GEMINI_PAID_PROJECT_ID',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-paid-project-id',
          optional: true,
        },
      },
      {
        secretKey: 'GEMINI_FLASH_MODEL',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-flash-model',
          optional: true,
        },
      },
      {
        secretKey: 'GEMINI_LITE_MODEL',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-lite-model',
          optional: true,
        },
      },
      {
        secretKey: 'GEMINI_PRO_MODEL',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-pro-model',
          optional: true,
        },
      },
      {
        secretKey: 'USDJPY_RATE',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-usdjpy-rate',
          optional: true,
        },
      },
    ],
  },
}
