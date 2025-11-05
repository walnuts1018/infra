(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name + '-aws',
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'minio_biscuit_secret_key',
      remoteRef: {
        key: 'minio-default-backup',
        property: 'minio_biscuit_secret_key',
      },
    },
  ],
  template_data: {
    credentials: (importstr './_config/aws-credentials.tmpl'),
  },
}
