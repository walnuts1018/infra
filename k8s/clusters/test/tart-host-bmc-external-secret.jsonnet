(import '../../components/external-secret.libsonnet') {
  name: 'rusk-bmc',
  namespace: (import 'cluster.json5').namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'username',
      remoteRef: {
        key: 'rusk-bmc',
        property: 'username',
      },
    },
    {
      secretKey: 'password',
      remoteRef: {
        key: 'rusk-bmc',
        property: 'password',
      },
    },
  ],
}
