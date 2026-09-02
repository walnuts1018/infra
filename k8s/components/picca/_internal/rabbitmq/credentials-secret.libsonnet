function(app) (import '../../../external-secret.libsonnet') {
  name: app.name + '-rabbitmq-user-credentials',
  namespace: app.namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'password',
      remoteRef: {
        key: 'terraform-external-secrets',
        property: app.name + '-rabbitmq-password',
      },
    },
  ],
  template_data: {
    username: app.name,
    password: '{{ .password }}',
  },
}
