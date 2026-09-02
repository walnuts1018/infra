function(app)
  local cluster = import '../../../../apps/rabbitmq-default/rabbitmqcluster.jsonnet';
  local vhost = (import 'vhost.libsonnet')(app);
  local user = (import 'user.libsonnet')(app);
  {
    apiVersion: 'rabbitmq.com/v1beta1',
    kind: 'Permission',
    metadata: {
      name: app.name,
      namespace: app.namespace,
    },
    spec: {
      vhost: vhost.spec.name,
      userReference: {
        name: user.metadata.name,
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
