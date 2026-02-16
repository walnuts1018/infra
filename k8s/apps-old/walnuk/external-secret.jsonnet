(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'scylladb_password',
      remoteRef: {
        key: 'scylladb',
        property: 'walnuk',
      },
    },
  ],
  template_data: {
    scylladb_username: 'walnuk',
    scylladb_password: '{{ .scylladb_password }}',
  },
}
