{
  apiVersion: 'multicluster.x-k8s.io/v1alpha1',
  kind: 'ServiceExport',
  metadata: {
    name: (import 'app.json5').name + '-kube-prom-prometheus',
    namespace: (import 'app.json5').namespace,
  },
}
