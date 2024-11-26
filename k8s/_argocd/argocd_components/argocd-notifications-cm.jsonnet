std.mergePatch(std.parseYaml(importstr 'argocd-notifications-cm.yaml'), {
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'argocd-notifications-cm',
    namespace: (import 'app.json5').namespace,
  },
  data: {
    'service.slack': 'token: $slack-token\nicon: :argo:\nusername: argocd',
  },
})
