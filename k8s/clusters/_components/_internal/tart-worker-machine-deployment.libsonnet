function(cluster, name, machineTemplateName, bootstrapConfigTemplateName, replicas) {
  apiVersion: 'cluster.x-k8s.io/v1beta2',
  kind: 'MachineDeployment',
  metadata: {
    name: name,
    namespace: cluster.namespace,
    labels: {
      'cluster.x-k8s.io/cluster-name': cluster.name,
    },
  },
  spec: {
    clusterName: cluster.name,
    replicas: replicas,
    selector: {},
    template: {
      metadata: {
        labels: {
          'cluster.x-k8s.io/cluster-name': cluster.name,
        },
      },
      spec: {
        clusterName: cluster.name,
        version: cluster.kubernetesVersion,
        bootstrap: {
          configRef: {
            apiGroup: 'bootstrap.cluster.x-k8s.io',
            kind: 'TartBootstrapConfigTemplate',
            name: bootstrapConfigTemplateName,
          },
        },
        infrastructureRef: {
          apiGroup: 'infrastructure.cluster.x-k8s.io',
          kind: 'TartMachineTemplate',
          name: machineTemplateName,
        },
      },
    },
  },
}
