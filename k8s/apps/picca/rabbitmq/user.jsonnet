local app = import '../app.json5';
{
  apiVersion: 'rabbitmq.com/v1beta1',
  kind: 'User',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    rabbitmqClusterReference: {
      name: 'default',
      namespace: 'rabbitmq',
    },
    importCredentialsSecret: {
      name: (import 'credentials-secret.jsonnet').spec.target.name,
    },
  },
}
