{
  apiVersion: 'external-secrets.io/v1',
  kind: 'ClusterExternalSecret',
  metadata: {
    name: 'ghcr-login-secret',
  },
  spec: {
    externalSecretName: 'ghcr-login-secret',
    namespaceSelector: {
      matchLabels: {
        'walnuts.dev/ghcr-login-secret': 'true',
      },
    },
    externalSecretSpec: {
      secretStoreRef: {
        name: 'onepassword',
        kind: 'ClusterSecretStore',
      },
      refreshInterval: '1m',
      target: {
        name: 'ghcr-login-secret',
        template: {
          type: 'kubernetes.io/dockerconfigjson',
        },
      },
      data: [
        {
          secretKey: '.dockerconfigjson',
          remoteRef: {
            key: 'github',
            property: '.dockerconfigjson',
          },
        },
      ],
    },
  },
}
