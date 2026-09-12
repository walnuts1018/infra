function(cluster, name, machineTemplateName, bootstrapConfigTemplateName, replicas) {
  local labels = {
    'cluster.x-k8s.io/cluster-name': cluster.name,
    'cluster.x-k8s.io/deployment-name': name,
  },
  apiVersion: 'cluster.x-k8s.io/v1beta2',
  kind: 'MachineDeployment',
  metadata: {
    name: name,
    namespace: cluster.namespace,
    labels: labels,
  },
  spec: {
    clusterName: cluster.name,
    replicas: replicas,
    selector: { matchLabels: labels },
    template: {
      metadata: {
        labels: labels,
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
