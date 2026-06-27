(import '../../components/external-secret.libsonnet') {
  name: 'argocd-notifications-secret',
  use_suffix: false,
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'slack-token',
      remoteRef: {
        key: 'argocd',
        property: 'slack-token',
      },
    },
    {
      secretKey: 'cloudflare-api-token',
      remoteRef: {
        key: 'cloudflare',
        property: 'argocd-webhook',
      },
    },
  ],
}
