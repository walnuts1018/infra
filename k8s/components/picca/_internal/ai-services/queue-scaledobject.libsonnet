function(app, workerName, queueName, minReplicaCount, maxReplicaCount, value, cooldownPeriod=300)
  {
    apiVersion: 'keda.sh/v1alpha1',
    kind: 'ScaledObject',
    metadata: {
      name: workerName,
      namespace: app.namespace,
    },
    spec: {
      pollingInterval: 5,
      cooldownPeriod: cooldownPeriod,
      minReplicaCount: minReplicaCount,
      maxReplicaCount: maxReplicaCount,
      scaleTargetRef: { name: workerName },
      triggers: [{
        type: 'rabbitmq',
        metricType: 'AverageValue',
        metadata: {
          protocol: 'http',
          queueName: queueName,
          mode: 'QueueLength',
          value: value,
        },
        authenticationRef: { name: app.name + '-rabbitmq-worker-auth' },
      }],
    },
  }
