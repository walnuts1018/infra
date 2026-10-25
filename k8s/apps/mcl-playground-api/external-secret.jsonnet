(import '../../components/external-secret.libsonnet') {
  name: (import 'app.json5').name,
  data: [
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'mcl-playground-database-password',
      },
    },
    {
      secretKey: 'rate_limit_hmac_secret',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'mcl-playground-rate-limit-secret',
      },
    },
  ],
  template_data: {
    DATABASE_URL: 'postgresql://mcl_playground:{{ .postgres_password | urlquery | replace "+" "%20" }}@postgresql-default-rw.databases.svc.cluster.local:5432/mcl_playground?sslmode=require&pool_max_conns=4',
    RATE_LIMIT_HMAC_SECRET: '{{ .rate_limit_hmac_secret }}',
  },
}
