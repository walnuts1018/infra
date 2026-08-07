local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: app.name + '-oidc',
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: 'shumoku',
        property: 'client_id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: 'shumoku',
        property: 'client_secret',
      },
    },
  ],
}
