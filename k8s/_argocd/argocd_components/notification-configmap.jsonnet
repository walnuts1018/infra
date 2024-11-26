{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'argocd-notifications-cm',
    namespace: (import 'app.json5').namespace,
  },
  data: {
    'service.slack': 'token: $slack-token',
  },
}
