local cluster = import 'cluster.json5';
{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ClusterSecretStore',
  metadata: {
    name: 'argocd-agent-biscuit',
  },
  spec: {
    conditions: [{ namespaces: [cluster.namespace] }],
    provider: {
      kubernetes: {
        remoteNamespace: 'argocd',
        server: {
          url: 'https://kubernetes.default.svc',
          caProvider: {
            type: 'ConfigMap',
            name: 'kube-root-ca.crt',
            namespace: 'argocd',
            key: 'ca.crt',
          },
        },
        auth: {
          serviceAccount: {
            name: 'argocd-agent-secret-reader-biscuit',
            namespace: 'argocd',
          },
        },
      },
    },
  },
}
