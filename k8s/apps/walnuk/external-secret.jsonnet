local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name,
  namespace: app.namespace,
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
