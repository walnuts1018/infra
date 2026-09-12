function(cluster, name, patchesSecretName) {
  apiVersion: 'bootstrap.cluster.x-k8s.io/v1alpha1',
  kind: 'TartBootstrapConfigTemplate',
  metadata: {
    name: name,
    namespace: cluster.namespace,
    annotations: { 'argocd.argoproj.io/sync-options': 'Prune=false' },
  },
  spec: {
    template: {
      spec: {
        configPatchesSecretRef: {
          name: patchesSecretName,
        },
      },
    },
  },
}
