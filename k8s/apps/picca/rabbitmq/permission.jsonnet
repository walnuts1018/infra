local app = import '../app.json5';
local cluster = (import '../../rabbitmq-default/rabbitmqcluster.jsonnet');
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
      name: cluster.metadata.name,
      namespace: cluster.metadata.namespace,
    },
  },
}
