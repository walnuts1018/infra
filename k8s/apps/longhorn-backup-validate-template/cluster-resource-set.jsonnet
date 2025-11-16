{
  apiVersion: 'addons.cluster.x-k8s.io/v1beta2',
  kind: 'ClusterResourceSet',
  metadata: {
    name: 'csi-proxmox',
    namespace: 'kaas',
  },
  spec: {
    strategy: 'Reconcile',
    clusterSelector: {
      matchLabels: {
        'cluster.x-k8s.io/cluster-name': (import '../longhorn-backup-validate/cluster.jsonnet').metadata.name,
      },
    },
    resources: [
      {
        kind: 'Secret',
        name: (import 'external-secret.jsonnet').spec.target.name,
      },
    ],
  },
}
