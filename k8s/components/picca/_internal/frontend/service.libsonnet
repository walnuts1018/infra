function(app)
  local labels = import '../../../labels.libsonnet';
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: app.name + '-frontend',
      namespace: app.namespace,
      labels: labels(app.name + '-frontend'),
    },
    spec: {
      selector: labels(app.name + '-frontend'),
      ports: [
        { name: 'http', port: 3000, targetPort: 3000 },
      ],
      type: 'ClusterIP',
    },
  }
