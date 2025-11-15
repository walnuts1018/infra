{
  apiVersion: 'cluster.x-k8s.io/v1beta2',
  kind: 'MachineDeployment',
  metadata: {
    labels: {
      'cluster.x-k8s.io/cluster-name': (import 'app.json5').name,
    },
    name: (import 'app.json5').name + '-worker',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    clusterName: (import 'app.json5').name,
    replicas: 1,
    selector: {
      matchLabels: {
        'cluster.x-k8s.io/cluster-name': (import 'app.json5').name,
      },
    },
    template: {
      metadata: {
        labels: {
          'cluster.x-k8s.io/cluster-name': (import 'app.json5').name,
          'node-role.kubernetes.io/worker': '',
        },
      },
      spec: {
        clusterName: (import 'app.json5').name,
        version: 'v1.34.1',  // TODO: auto update
        bootstrap: {
          configRef: {
            apiVersion: 'bootstrap.cluster.x-k8s.io/v1alpha3',
            kind: 'TalosConfigTemplate',
            name: (import 'talos-config-template.jsonnet').metadata.name,
          },
        },
        infrastructureRef: {
          apiVersion: 'infrastructure.cluster.x-k8s.io/v1alpha1',
          kind: 'KubevirtMachineTemplate',
          name: (import 'kubevirt-machine-template-worker.jsonnet').metadata.name,
          namespace: (import 'kubevirt-machine-template-worker.jsonnet').metadata.namespace,
        },
      },
    },
  },
}
