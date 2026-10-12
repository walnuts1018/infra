local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: 'horse-s3-credentials',
  namespace: app.namespace,
  use_suffix: false,
  spec+: {
    target+: {
      creationPolicy: 'Merge',
    },
  },
  data: [
    {
      secretKey: 'AWS_ACCESS_KEY_ID',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'horse-s3-access-key',
      },
    },
    {
      secretKey: 'AWS_SECRET_ACCESS_KEY',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'horse-s3-secret-key',
      },
    },
  ],
}
