(import '../../components/external-secret.libsonnet') {
  name: 'scylla-cluster-users',
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'admin_password',
      remoteRef: {
        key: 'scylladb',
        property: 'admin',
      },
    },
    {
      secretKey: 'walnuk_password',
      remoteRef: {
        key: 'scylladb',
        property: 'walnuk',
      },
    },
  ],
  template_data: {
    admin_username: 'cassandra',
    admin_password: '{{ .admin_password }}',
    'users.json': (importstr '_configs/users.json'),
  },
}
