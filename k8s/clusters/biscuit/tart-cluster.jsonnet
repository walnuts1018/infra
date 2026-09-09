{
  apiVersion: 'infrastructure.cluster.x-k8s.io/v1alpha1',
  kind: 'TartCluster',
  metadata: {
    name: (import 'cluster.json5').name,
    namespace: (import 'cluster.json5').namespace,
    labels: {
      'cluster.x-k8s.io/cluster-name': (import 'cluster.json5').name,
    },
  },
  // 単一node(control plane兼worker)構成でのcontrol planeへのPod scheduling許可や、
  // Cilium導入のためのdefault CNI(Flannel)無効化は、TartClusterSpecの専用fieldではなく
  // tart-bootstrap-patches-secret.jsonnetのraw config patch(KubeNodeConfig/KubeFlannelCNIConfig
  // への`$patch: delete`)で行う。
  spec: {},
}
