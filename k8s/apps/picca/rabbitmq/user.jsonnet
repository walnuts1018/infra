local app = import '../app.json5';
local cluster = (import '../../rabbitmq-default/rabbitmqcluster.jsonnet');
{
  apiVersion: 'rabbitmq.com/v1beta1',
  kind: 'User',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    rabbitmqClusterReference: {
      name: cluster.metadata.name,
      namespace: cluster.metadata.namespace,
    },
    importCredentialsSecret: {
      name: (import 'credentials-secret.jsonnet').spec.target.name,
    },
  },
}
