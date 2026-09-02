function(app)
  local worker = (import 'deployment.libsonnet')(app);
  {
    apiVersion: 'keda.sh/v1alpha1',
    kind: 'ScaledObject',
    metadata: { name: worker.metadata.name, namespace: app.namespace },
    spec: {
      pollingInterval: 5,
      minReplicaCount: 0,
      maxReplicaCount: 4,
      scaleTargetRef: { name: worker.metadata.name },
      triggers: [
        {
          type: 'rabbitmq',
          metricType: 'Value',
          metadata: { protocol: 'http', queueName: 'picca.library-auto-stack', mode: 'QueueLength', value: '1' },
          authenticationRef: { name: app.name + '-rabbitmq-worker-auth' },
        },
        {
          type: 'rabbitmq',
          metricType: 'Value',
          metadata: { protocol: 'http', queueName: 'picca.media-processing-notification', mode: 'QueueLength', value: '1' },
          authenticationRef: { name: app.name + '-rabbitmq-worker-auth' },
        },
      ],
    },
  }
