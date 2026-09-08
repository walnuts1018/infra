{
  apiVersion: 'controlplane.cluster.x-k8s.io/v1alpha1',
  kind: 'TartControlPlane',
  metadata: {
    name: (import 'cluster.json5').name,
    namespace: (import 'cluster.json5').namespace,
  },
  spec: {
    version: (import 'cluster.json5').kubernetesVersion,
    replicas: (import 'cluster.json5').controlPlaneMachineCount,
    machineTemplate: {
      spec: {
        infrastructureRef: {
          apiGroup: 'infrastructure.cluster.x-k8s.io',
          kind: 'TartMachineTemplate',
          name: (import 'tart-machine-template-control-plane.jsonnet').metadata.name,
        },
      },
    },
    bootstrapConfigTemplateRef: {
      apiGroup: 'bootstrap.cluster.x-k8s.io',
      kind: 'TartBootstrapConfigTemplate',
      name: (import 'tart-bootstrap-config-template.jsonnet').metadata.name,
    },
  },
}
