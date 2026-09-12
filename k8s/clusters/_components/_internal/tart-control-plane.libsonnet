function(cluster, machineTemplateName, bootstrapConfigTemplateName, replicas=cluster.controlPlaneMachineCount) {
  apiVersion: 'controlplane.cluster.x-k8s.io/v1alpha1',
  kind: 'TartControlPlane',
  metadata: {
    name: cluster.name,
    namespace: cluster.namespace,
  },
  spec: {
    version: cluster.kubernetesVersion,
    replicas: replicas,
    machineTemplate: {
      spec: {
        infrastructureRef: {
          apiGroup: 'infrastructure.cluster.x-k8s.io',
          kind: 'TartMachineTemplate',
          name: machineTemplateName,
        },
      },
    },
    bootstrapConfigTemplateRef: {
      apiGroup: 'bootstrap.cluster.x-k8s.io',
      kind: 'TartBootstrapConfigTemplate',
      name: bootstrapConfigTemplateName,
    },
  },
}
