(import '../../components/external-secret.libsonnet') {
  name: 'scylla-cluster-migrations',
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
    {
      secretKey: 'seaweedfs_password',
      remoteRef: {
        key: 'scylladb',
        property: 'seaweedfs',
      },
    },
  ],
  template_data: {
    admin_username: 'cassandra',
    admin_password: '{{ .admin_password }}',
    'migrations.cql': (importstr '_configs/migrations.cql'),
  },
}
