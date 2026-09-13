{
  apiVersion: 'v1',
  kind: 'Node',
  metadata: {
    name: 'cake',
    labels: {
      'node.longhorn.io/create-default-disk': 'config',
    },
    annotations: {
      'argocd.argoproj.io/sync-options': 'Prune=false',
      'node.longhorn.io/default-disks-config': |||
        [{"path":"/var/lib/longhorn/","allowScheduling":true},{"path":"/var/mnt/longhorn-extra","allowScheduling":true}]
      |||,
    },
  },
}
