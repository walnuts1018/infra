(import '../../components/external-secret.libsonnet') {
  name: 'rusk-bmc-ca',
  namespace: (import 'cluster.json5').namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'ca.crt',
      remoteRef: {
        key: 'rusk-bmc',
        property: 'certificate',
      },
    },
  ],
}
