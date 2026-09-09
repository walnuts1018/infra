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
      secretKey: 'prfexample_password',
      remoteRef: {
        key: 'scylladb',
        property: 'prfexample',
      },
    },
    {
      secretKey: 'picca_password',
      remoteRef: {
        key: 'scylladb',
        property: 'picca',
      },
    },
    {
      secretKey: 'picca_dev_password',
      remoteRef: {
        key: 'scylladb',
        property: 'picca_dev',
      },
    },
  ],
  template_data: {
    admin_username: 'cassandra',
    admin_password: '{{ .admin_password }}',
    'migrations.cql': (importstr '_configs/migrations.cql'),
  },
}
