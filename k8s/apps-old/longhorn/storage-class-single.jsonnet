{
  apiVersion: 'storage.k8s.io/v1',
  kind: 'StorageClass',
  metadata: {
    name: 'longhorn-single',
  },
  provisioner: 'driver.longhorn.io',
  allowVolumeExpansion: true,
  parameters: {
    numberOfReplicas: '1',
    staleReplicaTimeout: '30',
    fromBackup: '',
  },
  reclaimPolicy: 'Retain',
}
