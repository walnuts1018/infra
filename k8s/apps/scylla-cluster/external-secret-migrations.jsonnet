local externalSecret = import '../../components/external-secret.libsonnet';
local app = import 'app.json5';
local migrations = importstr '_configs/migrations.cql';
(externalSecret) {
  name: 'scylla-cluster-migrations',
  namespace: app.namespace,
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
    {
      secretKey: 'prfexample_password',
      remoteRef: {
        key: 'scylladb',
        property: 'prfexample',
      },
    },
  ],
  template_data: {
    admin_username: 'cassandra',
    admin_password: '{{ .admin_password }}',
    'migrations.cql': (migrations),
  },
}
