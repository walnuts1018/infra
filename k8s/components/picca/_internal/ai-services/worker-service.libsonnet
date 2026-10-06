function(app, workerName, workerLabels, port)
  [
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        name: workerName + '-backend',
        namespace: app.namespace,
        labels: workerLabels,
      },
      spec: {
        selector: workerLabels,
        ports: [{ name: 'http', port: port, targetPort: 'http' }],
        type: 'ClusterIP',
      },
    },
    {
      apiVersion: 'v1',
      kind: 'Service',
      metadata: {
        name: workerName,
        namespace: app.namespace,
        labels: workerLabels,
      },
      spec: {
        type: 'ExternalName',
        externalName: 'keda-add-ons-http-interceptor-proxy.keda.svc.cluster.local',
        ports: [{ name: 'http', port: 8080, targetPort: 8080 }],
      },
    },
  ]
