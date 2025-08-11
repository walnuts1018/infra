(import '../../../components/external-secret.libsonnet') {
  name: (import '../app.json5').backend.name,
  data: [
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'postgres_passwords/ac_hacking',
      },
    },
  ],
}
