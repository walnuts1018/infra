{
  apiVersion: 'external-secrets.io/v1beta1',
  kind: 'ExternalSecret',
  metadata: {
    name: 'argocd-oidc',
    namespace: (import 'app.libsonnet').namespace,
    labels: {
      app.kubernetes.io/part-of: "argocd",
    },
  },
  spec: {
    secretStoreRef: {
      name: 'onepassword',
      kind: 'ClusterSecretStore',
    },
    refreshInterval: '1m',
    target: {
      name: 'argocd-oidc',
    },
    data: [
      {
        secretKey: 'client-secret',
        remoteRef: {
          key: 'argocd-oidc',
          property: 'client-secret',
        },
      },
    ],
  },
}