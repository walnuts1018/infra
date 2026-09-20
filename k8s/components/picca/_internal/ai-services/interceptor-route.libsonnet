function(app, workerName, backendServiceName, port, targetValue)
  {
    apiVersion: 'http.keda.sh/v1beta1',
    kind: 'InterceptorRoute',
    metadata: {
      name: workerName,
      namespace: app.namespace,
    },
    spec: {
      target: {
        service: backendServiceName,
        port: port,
      },
      rules: [{
        hosts: [workerName + '.' + app.namespace + '.svc.cluster.local'],
      }],
      scalingMetric: {
        concurrency: {
          targetValue: targetValue,
        },
      },
    },
  }
