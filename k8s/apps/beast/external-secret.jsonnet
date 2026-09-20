local app = import 'app.json5';
[
  (import '../../components/external-secret.libsonnet') {
    name: app.name + '-postgres',
    namespace: app.namespace,
    use_suffix: false,
    data: [
      {
        secretKey: 'postgres_password',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: app.name + '-database-password',
        },
      },
    ],
    template_data: {
      DATABASE_URL: 'postgres://beast:{{ .postgres_password }}@postgresql-default-rw.databases.svc.cluster.local:5432/beast?sslmode=require&pool_max_conns=2',
    },
  },
  (import '../../components/picca/_internal/rabbitmq/external-secret.libsonnet')(app, false),
  (import '../../components/picca/_internal/rabbitmq/credentials-secret.libsonnet')(app),
  (import '../../components/picca/_internal/rabbitmq/vhost.libsonnet')(app),
  (import '../../components/picca/_internal/rabbitmq/user.libsonnet')(app),
  (import '../../components/picca/_internal/rabbitmq/permission.libsonnet')(app),
  (import '../../components/picca/_internal/oidc/external-secret.libsonnet')(app, false),
  (import '../../components/external-secret.libsonnet') {
    name: app.name + '-crypto',
    namespace: app.namespace,
    use_suffix: false,
    data: [
      {
        secretKey: 'staging_encryption_key',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: app.name + '-staging-encryption-key',
        },
      },
      {
        secretKey: 'media_encryption_key',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: app.name + '-media-encryption-key',
        },
      },
    ],
    template_data: {
      STAGING_ENCRYPTION_KEY: '{{ .staging_encryption_key }}',
      MEDIA_ENCRYPTION_KEY: '{{ .media_encryption_key }}',
    },
  },
]
