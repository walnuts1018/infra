// biscuit/kurumiなど、Tart provider配下のワークロードクラスタに共通するCluster CRの骨格。
function(
  cluster,
  controlPlaneEndpointHost,
  controlPlaneEndpointPort,
  controlPlaneRefName,
  infrastructureRefName,
  podCIDRs=['10.244.0.0/16'],
  serviceCIDRs=['10.96.0.0/12'],
) {
  apiVersion: 'cluster.x-k8s.io/v1beta2',
  kind: 'Cluster',
  metadata: {
    name: cluster.name,
    namespace: cluster.namespace,
    labels: {
      'cluster.x-k8s.io/cluster-name': cluster.name,
      'argocd-agent.walnuts.dev/enabled': 'true',
    },
    annotations: {
      'argocd.argoproj.io/sync-options': 'Prune=confirm,Delete=confirm',
    },
  },
  spec: {
    clusterNetwork: {
      pods: { cidrBlocks: podCIDRs },
      services: { cidrBlocks: serviceCIDRs },
    },
    controlPlaneEndpoint: {
      host: controlPlaneEndpointHost,
      port: controlPlaneEndpointPort,
    },
    controlPlaneRef: {
      apiGroup: 'controlplane.cluster.x-k8s.io',
      kind: 'TartControlPlane',
      name: controlPlaneRefName,
    },
    infrastructureRef: {
      apiGroup: 'infrastructure.cluster.x-k8s.io',
      kind: 'TartCluster',
      name: infrastructureRefName,
    },
  },
}
