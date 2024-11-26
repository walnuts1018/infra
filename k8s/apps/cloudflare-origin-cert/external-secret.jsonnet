{
  apiVersion: 'external-secrets.io/v1beta1',
  kind: 'ClusterExternalSecret',
  metadata: {
    name: 'cloudflare-origin-cert',
  },
  spec: {
    externalSecretName: 'cloudflare-origin-cert',
    namespaceSelector: {
      matchExpressions: [
        {
          key: 'kubernetes.io/metadata.name',
          operator: 'Exists',
        },
        {
          key: 'walnuts.dev/public',
          operator: 'DoesNotExist',
        },
      ],
    },
    externalSecretSpec: {
      secretStoreRef: {
        name: 'onepassword',
        kind: 'ClusterSecretStore',
      },
      refreshInterval: '1m',
      target: {
        name: 'cloudflare-origin-cert',
        template: {
          type: 'kubernetes.io/tls',
        },
      },
      data: [
        {
          secretKey: 'tls.crt',
          remoteRef: {
            key: 'cloudflare-origin-cert',
            property: 'tls.crt',
          },
        },
        {
          secretKey: 'tls.key',
          remoteRef: {
            key: 'cloudflare-origin-cert',
            property: 'tls.key',
          },
        },
      ],
    },
  },
}
