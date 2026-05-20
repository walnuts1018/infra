{
  apiVersion: 'rabbitmq.com/v1beta1',
  kind: 'Permission',
  metadata: {
    name: 'picca-ai-prototype-app-permission',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name + '-rabbitmq-permission'),
  },
  spec: {
    vhost: '/',
    userReference: {
      name: (import './rabbitmq-user.jsonnet').metadata.name,
    },
    permissions: {
      configure: '.*',
      write: '.*',
      read: '.*',
    },
    rabbitmqClusterReference: {
      name: 'default',
      namespace: 'rabbitmq',
    },
  },
}
