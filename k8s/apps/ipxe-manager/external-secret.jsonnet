(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'ipxe-manager',
        property: 'client-secret',
      },
    },
  ],
}
