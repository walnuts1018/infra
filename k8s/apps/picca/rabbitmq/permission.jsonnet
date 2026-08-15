local app = import '../app.json5';
{
  apiVersion: 'rabbitmq.com/v1beta1',
  kind: 'Permission',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    vhost: (import 'vhost.jsonnet').spec.name,
    userReference: {
      name: (import 'user.jsonnet').metadata.name,
    },
    permissions: {
      write: '.*',
      configure: '.*',
      read: '.*',
    },
    rabbitmqClusterReference: {
      name: 'default',
      namespace: 'rabbitmq',
    },
  },
}
