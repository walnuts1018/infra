{
  apiVersion: 'cluster.x-k8s.io/v1beta2',
  kind: 'MachineDeployment',
  metadata: {
    labels: {
      'cluster.x-k8s.io/cluster-name': (import 'cluster.jsonnet').metadata.name,
    },
    name: (import '../app.json5').name + '-worker',
    namespace: (import '../app.json5').namespace,
  },
  spec: {
    clusterName: (import 'cluster.jsonnet').metadata.name,
    replicas: 1,
    selector: {
      matchLabels: {
        'cluster.x-k8s.io/cluster-name': (import 'cluster.jsonnet').metadata.name,
      },
    },
    template: {
      metadata: {
        labels: {
          'cluster.x-k8s.io/cluster-name': (import 'cluster.jsonnet').metadata.name,
          'node-role.kubernetes.io/worker': '',
        },
      },
      spec: {
        clusterName: (import 'cluster.jsonnet').metadata.name,
        version: 'v1.34.1',  // TODO: auto update
        bootstrap: {
          configRef: {
            apiGroup: 'bootstrap.cluster.x-k8s.io',
            kind: 'TalosConfigTemplate',
            name: (import '../../longhorn-backup-validate-template/talos-config-template.jsonnet').metadata.name,
          },
        },
        infrastructureRef: {
          apiGroup: 'infrastructure.cluster.x-k8s.io',
          kind: 'KubevirtMachineTemplate',
          name: (import '../../longhorn-backup-validate-template/kubevirt-machine-template-worker.jsonnet').metadata.name,
        },
      },
    },
  },
}
