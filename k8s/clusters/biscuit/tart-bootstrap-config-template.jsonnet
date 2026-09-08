{
  apiVersion: 'bootstrap.cluster.x-k8s.io/v1alpha1',
  kind: 'TartBootstrapConfigTemplate',
  metadata: {
    name: (import 'cluster.json5').name + '-control-plane',
    namespace: (import 'cluster.json5').namespace,
  },
  spec: {
    template: {
      spec: {
        configPatchesSecretRef: {
          name: (import 'tart-bootstrap-patches-secret.jsonnet').metadata.name,
        },
      },
    },
  },
}
