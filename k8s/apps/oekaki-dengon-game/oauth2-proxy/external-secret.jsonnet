local app = import '../app.json5';
(import '../../../components/external-secret.libsonnet') {
  name: app.name + '-secret',
  data: [
    {
      secretKey: 'client-id',
      remoteRef: {
        key: app.name,
        property: 'client_id',
      },
    },
    {
      secretKey: 'client-secret',
      remoteRef: {
        key: app.name,
        property: 'client_secret',
      },
    },
  ],
}
