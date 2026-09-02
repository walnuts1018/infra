function(app)
  local labels = import '../../../labels.libsonnet';
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: app.name + '-apiserver',
      namespace: app.namespace,
      labels: labels(app.name + '-apiserver'),
    },
    spec: {
      selector: labels(app.name + '-apiserver'),
      ports: [
        { name: 'http', port: 8080, targetPort: 8080 },
      ],
      type: 'ClusterIP',
    },
  }
