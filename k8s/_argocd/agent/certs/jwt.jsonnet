{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ExternalSecret',
  metadata: {
    name: 'argocd-agent-jwt',
    namespace: 'argocd',
    annotations: {
      'argocd.argoproj.io/sync-wave': '-3',
    },
  },
  spec: {
    refreshInterval: '1h',
    secretStoreRef: {
      kind: 'ClusterSecretStore',
      name: 'onepassword',
    },
    target: {
      name: 'argocd-agent-jwt',
      creationPolicy: 'Owner',
      template: {
        engineVersion: 'v2',
        type: 'Opaque',
      },
    },
    data: [
      {
        secretKey: 'jwt.key',
        remoteRef: {
          key: 'argocd-agent-jwt',
          property: 'file/jwt.key',
        },
      },
    ],
  },
}
