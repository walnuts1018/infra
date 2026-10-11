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
        secretKey: 'GEMINI_API_KEY',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-api-key',
          optional: true,
        },
      },
      {
        secretKey: 'GEMINI_MODEL',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-model',
          optional: true,
        },
      },
      {
        secretKey: 'GEMINI_FALLBACK_MODEL',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: 'horse-gemini-fallback-model',
          optional: true,
        },
      },
    ],
  },
}
