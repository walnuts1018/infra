(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-oidc-secret',
  data: [
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'http-dump',
        property: 'client-secret',
      },
    },
  ],
}
