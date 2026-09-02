function(app) {
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: app.name + '-scylla-secret-reader',
    namespace: app.namespace,
  },
}
