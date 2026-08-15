local app = import '../app.json5';
{
  apiVersion: 'rabbitmq.com/v1beta1',
  kind: 'Vhost',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    name: app.name,
    rabbitmqClusterReference: {
      name: 'default',
      namespace: 'rabbitmq',
    },
  },
}
