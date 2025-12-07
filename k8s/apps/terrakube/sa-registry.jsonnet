{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: (import 'app.json5').name + '-registry',
    namespace: (import 'app.json5').namespace,
  },
}
