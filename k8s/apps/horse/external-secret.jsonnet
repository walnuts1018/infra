(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'client_id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'horse-client-id',
      },
    },
    {
      secretKey: 'client_secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'horse-client-secret',
      },
    },
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'horse-database-password',
      },
    },
    {
      secretKey: 'rabbitmq_password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'horse-rabbitmq-password',
      },
    },
    {
      secretKey: 'email_body_encryption_keys',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'horse-email-body-encryption-keys',
      },
    },
  ],
  template_data: {
    DATABASE_URL: 'postgresql://horse:{{ .postgres_password }}@postgresql-default-rw.databases.svc.cluster.local:5432/horse',
    POSTGRES_PASSWORD: '{{ .postgres_password }}',
    OIDC_CLIENT_ID: '{{ .client_id }}',
    OIDC_CLIENT_SECRET: '{{ .client_secret }}',
    RABBITMQ_URL: 'amqp://horse:{{ .rabbitmq_password }}@default.rabbitmq.svc.cluster.local:5672/horse',
    EMAIL_BODY_ENCRYPTION_KEYS: '{{ .email_body_encryption_keys }}',
  },
  metadata+: {
    annotations: { 'argocd.argoproj.io/sync-wave': '-2' },
  },
}
