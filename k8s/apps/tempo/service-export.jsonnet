{
  apiVersion: 'multicluster.x-k8s.io/v1alpha1',
  kind: 'ServiceExport',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
}
