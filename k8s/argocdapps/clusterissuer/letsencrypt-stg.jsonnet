{
  apiVersion: 'cert-manager.io/v1',
  kind: 'ClusterIssuer',
  metadata: {
    name: 'letsencrypt-stg',
  },
  spec: {
    acme: {
      server: 'https://acme-staging-v02.api.letsencrypt.org/directory',
      email: 'r.juglans.1018@gmail.com',
      privateKeySecretRef: {
        name: 'letsencrypt-stg',
      },
      solvers: [
        {
          dns01: {
            cloudflare: {
              apiTokenSecretRef: {
                name: (import 'external-secret.jsonnet').spec.target.name,
                key: 'api-token',
              },
            },
          },
        },
      ],
    },
  },
}
