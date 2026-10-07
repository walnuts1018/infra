local externalSecret = import '../../components/external-secret.libsonnet';
externalSecret {
  name: 'penpot-secrets',
  namespace: (import 'app.json5').namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'oidcClientID',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'penpot-client-id',
      },
    },
    {
      secretKey: 'oidcClientSecret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'penpot-client-secret',
      },
    },
    {
      secretKey: 'oidcRequiredRole',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'penpot-oidc-required-role',
      },
    },
    {
      secretKey: 'apiSecretKey',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'penpot-api-secret-key',
      },
    },
    {
      secretKey: 'databasePassword',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'penpot-database-password',
      },
    },
    {
      secretKey: 'redisPassword',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'penpot-redis-password',
      },
    },
  ],
  template_data: {
    'api-secret-key': '{{ .apiSecretKey }}',
    'oidc-client-id': '{{ .oidcClientID }}',
    'oidc-client-secret': '{{ .oidcClientSecret }}',
    'oidc-required-role': '{{ .oidcRequiredRole }}',
    username: 'penpot',
    password: '{{ .databasePassword }}',
    'database-uri': 'postgresql://postgresql-default-rw.databases.svc.cluster.local:5432/penpot',
    'redis-password': '{{ .redisPassword }}',
    'redis-uri': 'redis://:{{ .redisPassword }}@penpot-valkey.penpot.svc.cluster.local:6379/0',
  },
}
