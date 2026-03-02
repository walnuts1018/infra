(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'scylladb_password',
      remoteRef: {
        key: 'scylladb',
        property: 'prfexample',
      },
    },
  ],
  template_data: {
    scylladb_username: 'prfexample',
    scylladb_password: '{{ .scylladb_password }}',
  },
}
