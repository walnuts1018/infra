{
  apiVersion: 'controlplane.cluster.x-k8s.io/v1alpha3',
  kind: 'TalosControlPlane',
  metadata: {
    name: (import '../app.json5').name + '-control-plane',
    namespace: (import '../app.json5').namespace,
  },
  spec: {
    version: 'v1.34.1',  // TODO: auto update
    replicas: 1,
    infrastructureTemplate: {
      apiVersion: 'infrastructure.cluster.x-k8s.io/v1alpha1',
      kind: 'KubevirtMachineTemplate',
      name: (import '../../longhorn-backup-validate-template/kubevirt-machine-template-control-plane.jsonnet').metadata.name,
      namespace: (import '../../longhorn-backup-validate-template/kubevirt-machine-template-control-plane.jsonnet').metadata.namespace,
    },
    controlPlaneConfig: {
      controlplane: {
        generateType: 'controlplane',
        talosVersion: 'v1.11.5',  // TODO: auto update
      },
    },
  },
}
