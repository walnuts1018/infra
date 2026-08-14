(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'stalwart',
      },
    },
    {
      secretKey: 's3_secret_access_key',
      remoteRef: {
        key: 'seaweedfs',
        property: 'stalwart_secretkey',
      },
    },
  ],
  template_data: {
    postgres_password: '{{ .postgres_password }}',
    s3_secret_access_key: '{{ .s3_secret_access_key }}',
    s3_access_key: 'stalwart',
  },
}
