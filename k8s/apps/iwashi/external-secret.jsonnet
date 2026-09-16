local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  data: [
    { secretKey: 'client_id', remoteRef: { key: 'terraform-external-secrets', property: 'iwashi-client-id' } },
    { secretKey: 'client_secret', remoteRef: { key: 'terraform-external-secrets', property: 'iwashi-client-secret' } },
    { secretKey: 'database_password', remoteRef: { key: 'terraform-external-secrets', property: 'iwashi-database-password' } },
    { secretKey: 'session_key', remoteRef: { key: 'terraform-external-secrets', property: 'iwashi-session-key' } },
    { secretKey: 'discovery_key', remoteRef: { key: 'terraform-external-secrets', property: 'iwashi-discovery-key' } },
    { secretKey: 'smtp_password', remoteRef: { key: 'resend', property: 'api-key' } },
  ],
  template_data: {
    OIDC_CLIENT_ID: '{{ .client_id }}',
    OIDC_CLIENT_SECRET: '{{ .client_secret }}',
    SESSION_KEY: '{{ .session_key }}',
    DISCOVERY_KEY: '{{ .discovery_key }}',
    DATABASE_URL: 'postgres://iwashi:{{ .database_password }}@postgresql-default-rw.databases.svc.cluster.local:5432/iwashi?sslmode=require&pool_max_conns=2',
    SMTP_PASSWORD: '{{ .smtp_password }}',
  },
}
