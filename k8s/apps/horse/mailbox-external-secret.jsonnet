(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-mailbox',
  namespace: (import 'app.json5').namespace,
  use_suffix: false,
  metadata+: {
    annotations: {
      'argocd.argoproj.io/sync-wave': '3',
    },
  },
  data: [
    {
      secretKey: 'username',
      remoteRef: {
        key: 'horse-mailbox',
        property: 'username',
      },
    },
    {
      secretKey: 'password',
      remoteRef: {
        key: 'horse-mailbox',
        property: 'password',
      },
    },
  ],
}
