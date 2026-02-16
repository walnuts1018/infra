{
  apiVersion: 'storage.k8s.io/v1',
  kind: 'StorageClass',
  metadata: {
    name: 'longhorn-single-encrypted',
  },
  provisioner: 'driver.longhorn.io',
  allowVolumeExpansion: true,
  parameters: {
    numberOfReplicas: '1',
    staleReplicaTimeout: '30',
    fromBackup: '',
    encrypted: 'true',
    local secretName = '${pvc.name}',
    local secretNamespace = '${pvc.namespace}',
    'csi.storage.k8s.io/provisioner-secret-name': secretName,
    'csi.storage.k8s.io/provisioner-secret-namespace': secretNamespace,
    'csi.storage.k8s.io/node-publish-secret-name': secretName,
    'csi.storage.k8s.io/node-publish-secret-namespace': secretNamespace,
    'csi.storage.k8s.io/node-stage-secret-name': secretName,
    'csi.storage.k8s.io/node-stage-secret-namespace': secretNamespace,
    'csi.storage.k8s.io/node-expand-secret-name': secretName,
    'csi.storage.k8s.io/node-expand-secret-namespace': secretNamespace,

  },
  reclaimPolicy: 'Retain',
}
