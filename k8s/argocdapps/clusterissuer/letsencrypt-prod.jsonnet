{
  apiVersion: 'cert-manager.io/v1',
  kind: 'ClusterIssuer',
  metadata: {
    name: 'letsencrypt-prod',
  },
  spec: {
    acme: {
      server: 'https://acme-v02.api.letsencrypt.org/directory',
      email: 'r.juglans.1018@gmail.com',
      privateKeySecretRef: {
        name: 'letsencrypt-prod',
      },
      solvers: [
        {
          dns01: {
            cloudflare: {
              apiTokenSecretRef: {
                name: (import 'external-secret.jsonnet').name,
                key: 'api-token',
              },
            },
          },
        },
      ],
    },
  },
}
