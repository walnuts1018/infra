{
  apiVersion: 'storage.k8s.io/v1',
  kind: 'StorageClass',
  metadata: {
    name: 'longhorn-coder-workspace',
  },
  provisioner: 'driver.longhorn.io',
  allowVolumeExpansion: true,
  parameters: {
    numberOfReplicas: '1',
    dataLocality: 'best-effort',
    staleReplicaTimeout: '30',
    fromBackup: '',
  },
  reclaimPolicy: 'Delete',
}
