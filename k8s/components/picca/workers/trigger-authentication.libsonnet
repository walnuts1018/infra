function(app)
  local rabbitmqSecret = (import '../rabbitmq/secret.libsonnet')(app);
  {
    apiVersion: 'keda.sh/v1alpha1',
    kind: 'TriggerAuthentication',
    metadata: {
      name: app.name + '-rabbitmq-worker-auth',
      namespace: app.namespace,
    },
    spec: {
      secretTargetRef: [
        {
          parameter: 'host',
          name: rabbitmqSecret.spec.target.name,
          key: 'KEDA_RABBITMQ_HOST',
        },
      ],
    },
  }
