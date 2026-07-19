{
  apiVersion: 'controlplane.cluster.x-k8s.io/v1beta2',
  kind: 'KubeadmControlPlane',
  metadata: {
    name: (import 'cluster.json5').name,
    namespace: (import 'cluster.json5').namespace,
  },
  spec: {
    replicas: (import 'cluster.json5').controlPlaneMachineCount,
    version: (import 'cluster.json5').kubernetesVersion,
    kubeadmConfigSpec: {
      initConfiguration: {
        nodeRegistration: {
          taints: [],
        },
      },
      joinConfiguration: {
        nodeRegistration: {
          taints: [],
        },
      },
    },
    machineTemplate: {
      spec: {
        infrastructureRef: {
          apiGroup: 'infrastructure.cluster.x-k8s.io',
          kind: 'TartMachineTemplate',
          name: (import 'tart-machine-template-control-plane.jsonnet').metadata.name,
        },
      },
    },
  },
}
