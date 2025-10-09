{
  apiVersion: 'snapshot.storage.k8s.io/v1',
  kind: 'VolumeSnapshotClass',
  metadata: {
    name: 'longhorn',
  },
  driver: 'driver.longhorn.io',
  deletionPolicy: 'Delete',
  parameters: {
    type: 'bak',
  },
}
