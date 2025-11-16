{
  apiVersion: 'bootstrap.cluster.x-k8s.io/v1alpha3',
  kind: 'TalosConfigTemplate',
  metadata: {
    name: (import 'app.json5').name + 'worker',
  },
  spec: {
    template: {
      spec: {
        generateType: 'join',
        talosVersion: 'v1.11.5',  // TODO: auto update
      },
    },
  },
}
