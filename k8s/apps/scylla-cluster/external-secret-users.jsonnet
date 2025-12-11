(import '../../components/external-secret.libsonnet') {
  name: 'scylla-cluster-users',
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'walnuk_password',
      remoteRef: {
        key: 'scylladb',
        property: 'walnuk',
      },
    },
  ],
  template_data: {
    'users.json': (importstr '_configs/users.json'),
  },
}
