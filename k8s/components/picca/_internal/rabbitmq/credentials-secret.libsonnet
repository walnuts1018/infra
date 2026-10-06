function(app)
  local externalSecret = (import '../../../external-secret.libsonnet') {
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
  };
  externalSecret {
    spec+: {
      target+: {
        template+: {
          metadata: {
            labels: {
              'rabbitmq.com/topology-operator': 'true',
            },
          },
        },
      },
    },
  }
