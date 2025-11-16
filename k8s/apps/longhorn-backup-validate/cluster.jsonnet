{
  apiVersion: 'cluster.x-k8s.io/v1beta2',
  kind: 'Cluster',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    clusterNetwork: {
      pods: {
        cidrBlocks: ['10.243.0.0/16'],
      },
      services: {
        cidrBlocks: ['10.95.0.0/16'],
      },
    },
    infrastructureRef: {
      apiGroup: 'infrastructure.cluster.x-k8s.io/v1alpha1',
      kind: 'KubevirtCluster',
      name: (import 'kubevirt-cluster.jsonnet').metadata.name,
      namespace: (import 'kubevirt-cluster.jsonnet').metadata.namespace,
    },
    controlPlaneRef: {
      apiGroup: 'controlplane.cluster.x-k8s.io/v1alpha3',
      kind: 'TalosControlPlane',
      name: (import 'talos-control-plane.jsonnet').metadata.name,
      namespace: (import 'talos-control-plane.jsonnet').metadata.namespace,
    },
  },
}
