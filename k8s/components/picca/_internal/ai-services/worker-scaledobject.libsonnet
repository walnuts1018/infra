function(app, workerName)
  {
    apiVersion: 'keda.sh/v1alpha1',
    kind: 'ScaledObject',
    metadata: {
      name: workerName,
      namespace: app.namespace,
    },
    spec: {
      pollingInterval: 5,
      cooldownPeriod: 300,
      minReplicaCount: 0,
      maxReplicaCount: 1,
      scaleTargetRef: { name: workerName },
      triggers: [{
        type: 'external-push',
        metadata: {
          scalerAddress: 'keda-add-ons-http-external-scaler.keda:9090',
          interceptorRoute: workerName,
        },
      }],
    },
  }
