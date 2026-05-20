(import '../../components/external-secret.libsonnet') {
  name: 'rabbitmq-app-user',
  namespace: (import 'app.json5').namespace,
  use_suffix: false,
  data: [
    {
      secretKey: 'username',
      remoteRef: {
        key: 'picca-ai-prototype',
        property: 'rabbitmq_username',
      },
    },
    {
      secretKey: 'password',
      remoteRef: {
        key: 'picca-ai-prototype',
        property: 'rabbitmq_password',
      },
    },
  ],
  template_data: {
    amqp_url: 'amqp://{{ .username }}:{{ .password }}@default.rabbitmq.svc.cluster.local:5672/%2F',
    uri: 'http://default.rabbitmq.svc.cluster.local:15672',
  },
}
