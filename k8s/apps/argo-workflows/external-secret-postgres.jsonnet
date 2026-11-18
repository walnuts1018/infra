local app = import 'app.json5';
(import '../../components/external-secret.libsonnet') {
  name: 'argo-workflows-postgres-config',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: 'argo-workflows-database-password',
      },
    },
  ],
  template_data: {
    username: 'argo_workflows',
    password: '{{ .password }}',
  },
}
