(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-filer-config',
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'scylladb_password',
      remoteRef: {
        key: 'scylladb',
        property: 'seaweedfs',
      },
    },
    {
      secretKey: 'sts_signing_key',
      remoteRef: {
        key: 'seaweedfs',
        property: 'sts_signing_key',
      },
    },
  ],
  template_data: {
    'filer.toml': (importstr '_configs/filer.toml'),
    'iam.json': (importstr '_configs/iam.json'),
  },
}
