(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-mailbox',
  namespace: (import 'app.json5').namespace,
  use_suffix: false,
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
