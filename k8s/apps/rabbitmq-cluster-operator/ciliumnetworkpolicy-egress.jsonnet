local app = import 'app.json5';
(import '../../components/rabbitmq-operator/network-policy.libsonnet')(
  app,
  'rabbitmq-operator',
)
