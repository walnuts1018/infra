local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
(externalSecret) {
  name: 'argocd-notifications-secret',
  use_suffix: false,
  namespace: app.namespace,
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
