function(app, useSuffix=true)
  (import '../../../external-secret.libsonnet') {
    name: app.name + '-rabbitmq',
    namespace: app.namespace,
    use_suffix: useSuffix,
    data: [
      {
        secretKey: 'rabbitmq_password',
        remoteRef: {
          key: 'terraform-external-secrets',
          property: app.name + '-rabbitmq-password',
        },
      },
    ],
    template_data: {
      RABBITMQ_URL: 'amqp://' + app.name + ':{{ .rabbitmq_password }}@default.rabbitmq.svc.cluster.local:5672/' + app.name,
      KEDA_RABBITMQ_HOST: 'http://' + app.name + ':{{ .rabbitmq_password }}@default.rabbitmq.svc.cluster.local:15672/' + app.name,
    },
  }
