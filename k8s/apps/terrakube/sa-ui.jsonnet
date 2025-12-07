{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: (import 'app.json5').name + '-ui',
    namespace: (import 'app.json5').namespace,
  },
}
