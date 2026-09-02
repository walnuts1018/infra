function(app)
  local labels = import '../../../labels.libsonnet';
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: app.name + '-sparse-service',
      namespace: app.namespace,
      labels: labels(app.name + '-sparse-service'),
    },
    spec: {
      selector: labels(app.name + '-sparse-service'),
      ports: [
        { name: 'http', port: 8002, targetPort: 'http' },
      ],
      type: 'ClusterIP',
    },
  }
