(import '../../components/external-secret.libsonnet') {
  name: 'scylla-cluster-migrations',
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'scylladb_password',
      remoteRef: {
        key: 'scylladb',
        property: 'seaweedfs',
      },
    },
  ],
  template_data: {
    'filer.toml': (importstr '_configs/filer.toml'),
  },
}
