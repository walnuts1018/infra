{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
}
