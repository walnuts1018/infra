function(app)
  local cluster = import '../../../apps/rabbitmq-default/rabbitmqcluster.jsonnet';
  local credentialsSecret = (import 'credentials-secret.libsonnet')(app);
  {
    apiVersion: 'rabbitmq.com/v1beta1',
    kind: 'User',
    metadata: {
      name: app.name,
      namespace: app.namespace,
    },
    spec: {
      tags: ['monitoring'],
      rabbitmqClusterReference: {
        name: cluster.metadata.name,
        namespace: cluster.metadata.namespace,
      },
      importCredentialsSecret: {
        name: credentialsSecret.spec.target.name,
      },
    },
  }
