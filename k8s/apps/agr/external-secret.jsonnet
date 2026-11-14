local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'database_password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'agr-database-password',
      },
    },
    {
      secretKey: 'gateway_token',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'agr-gateway-token',
      },
    },
  ],
  template_data: {
    DATABASE_URL: 'postgresql://agr:{{ .database_password }}@postgresql-default-rw.databases.svc.cluster.local:5432/agr?sslmode=disable',
    SERVICE_GATEWAY_TOKEN: '{{ .gateway_token }}',
  },
}
