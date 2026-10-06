local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: 'coder-db-url',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'database_password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'coder-database-password',
      },
    },
  ],
  template_data: {
    url: 'postgres://coder:{{ .database_password }}@postgresql-default-rw.databases.svc.cluster.local:5432/coder?sslmode=require',
  },
}
