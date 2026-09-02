function(app) {
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
}
