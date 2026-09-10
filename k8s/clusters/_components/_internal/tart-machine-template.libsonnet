function(cluster, name, hostSelectorLabels, schematicID) {
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1alpha1',
  kind: 'TartMachineTemplate',
  metadata: {
    name: name,
    namespace: cluster.namespace,
  },
  spec: {
    template: {
      spec: {
        hostSelector: {
          selector: {
            matchLabels: hostSelectorLabels,
          },
        },
        image: {
          version: cluster.talosVersion,
          schematicID: schematicID,
        },
      },
    },
  },
}
