local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  data: [
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'postgres_passwords',
        property: 'picca',
      },
    },
    {
      secretKey: 'scylla_password',
      remoteRef: {
        key: 'scylladb',
        property: 'picca',
      },
    },
    {
      secretKey: 'valkey_password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'picca-redis-password',
      },
    },
    {
      secretKey: 'imgproxy_key',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'picca-imgproxy-key',
      },
    },
    {
      secretKey: 'imgproxy_salt',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'picca-imgproxy-salt',
      },
    },
    {
      secretKey: 'graphql_query_signing_secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'picca-graphql-query-signing-secret',
      },
    },
    {
      secretKey: 'oidc_client_id',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'picca-client-id',
      },
    },
    {
      secretKey: 'oidc_client_secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'picca-client-secret',
      },
    },
    {
      secretKey: 'rabbitmq_password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'picca-rabbitmq-password',
      },
    },
  ],
  template_data: {
    DATABASE_URL: 'postgres://picca:{{ .postgres_password }}@postgresql-default-rw.databases.svc.cluster.local:5432/picca',
    SCYLLA_PASSWORD: '{{ .scylla_password }}',
    VALKEY_URL: 'redis://:{{ .valkey_password }}@valkey-picca-valkey.picca.svc.cluster.local:6379/0',
    valkey_password: '{{ .valkey_password }}',
    IMGPROXY_KEY: '{{ .imgproxy_key }}',
    IMGPROXY_SALT: '{{ .imgproxy_salt }}',
    GRAPHQL_QUERY_SIGNING_SECRET: '{{ .graphql_query_signing_secret }}',
    PICCA_GRAPHQL_QUERY_SIGNING_SECRET: '{{ .graphql_query_signing_secret }}',
    OIDC_CLIENT_ID: '{{ .oidc_client_id }}',
    OIDC_CLIENT_SECRET: '{{ .oidc_client_secret }}',
    RABBITMQ_URL: 'amqp://picca:{{ .rabbitmq_password }}@default.rabbitmq.svc.cluster.local:5672/picca',
  },
}
