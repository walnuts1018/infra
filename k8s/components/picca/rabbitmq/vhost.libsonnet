function(app)
  local cluster = import '../../../apps/rabbitmq-default/rabbitmqcluster.jsonnet';
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
        name: cluster.metadata.name,
        namespace: cluster.metadata.namespace,
      },
    },
  }
