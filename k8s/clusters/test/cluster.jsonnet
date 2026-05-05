{
  apiVersion: 'cluster.x-k8s.io/v1beta2',
  kind: 'Cluster',
  metadata: {
    name: (import 'cluster.json5').name,
    namespace: (import 'cluster.json5').namespace,
    labels: {
      'cluster.x-k8s.io/cluster-name': (import 'cluster.json5').name,
    },
  },
  spec: {
    clusterNetwork: {
      pods: {
        cidrBlocks: ['10.0.0.0/16'],
      },
      services: {
        cidrBlocks: ['10.96.0.0/12'],
      },
    },
    controlPlaneEndpoint: {
      host: '192.168.0.15',
      port: '6443',
    },
    controlPlaneRef: {
      apiGroup: 'controlplane.cluster.x-k8s.io',
      kind: 'KubeadmControlPlane',
      name: (import 'kubeadm-control-plane.jsonnet').metadata.name,
    },
    infrastructureRef: {
      apiGroup: 'infrastructure.cluster.x-k8s.io',
      kind: 'TartCluster',
      name: (import 'tart-cluster.jsonnet').metadata.name,
    },
  },
}
