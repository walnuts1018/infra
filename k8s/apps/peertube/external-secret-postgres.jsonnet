local app = import 'app.json5';

(import '../../components/external-secret.libsonnet') {
  name: app.name + '-postgres',
  namespace: app.namespace,
  data: [
    {
      secretKey: 'postgres_password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'peertube-database-password',
      },
    },
  ],
  template_data: {
    'postgres-username': 'peertube',
    'postgres-password': '{{ .postgres_password }}',
  },
}
