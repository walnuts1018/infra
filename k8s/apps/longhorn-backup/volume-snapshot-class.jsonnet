{
  apiVersion: 'snapshot.storage.k8s.io/v1',
  kind: 'VolumeSnapshotClass',
  metadata: {
    name: 'longhorn',
    annotations: {
      'snapshot.storage.kubernetes.io/is-default-class': 'true',  // TODO: 複数Classができたらどうにかしたくなるだろう
    },
  },
  driver: 'driver.longhorn.io',
  deletionPolicy: 'Retain',
  parameters: {
    type: 'bak',
  },
}
