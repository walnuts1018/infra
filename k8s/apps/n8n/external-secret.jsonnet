(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'postgres-password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'n8n',
      },
    },
  ],
}
