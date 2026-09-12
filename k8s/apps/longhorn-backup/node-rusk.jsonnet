{
  apiVersion: 'v1',
  kind: 'Node',
  metadata: {
    name: 'rusk',
    labels: {
      'node.longhorn.io/create-default-disk': 'config',
    },
    annotations: {
      'node.longhorn.io/default-disks-config': '[{"path":"/var/lib/longhorn/","allowScheduling":true}]',
    },
  },
}
