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
  spec: {
    // 単一node(control plane兼worker)構成のため、通常のPodをcontrol planeへscheduleできる
    // ようにする。CiliumをArgoCD側で別途管理するため、TalosのCNI自動install(Flannel)は
    // 無効化する。
    allowSchedulingOnControlPlanes: true,
    disableDefaultCNI: true,
  },
}
