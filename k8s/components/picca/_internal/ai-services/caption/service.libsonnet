function(app)
  local labels = import '../../../../labels.libsonnet';
  local name = app.name + '-caption-worker';
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: name,
      namespace: app.namespace,
      labels: labels(name),
    },
    spec: {
      selector: labels(name),
      ports: [{ name: 'http', port: 8004, targetPort: 'http' }],
      type: 'ClusterIP',
    },
  }
