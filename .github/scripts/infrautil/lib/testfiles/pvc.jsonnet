[
  {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'photoprism-import',
    },
    spec: {
      storageClassName: 'longhorn-local',
      accessModes: [
        'ReadWriteOnce',
      ],
      resources: {
        requests: {
          storage: '2Gi',
        },
      },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'photoprism-cache',
    },
    spec: {
      storageClassName: 'longhorn-local',
      accessModes: [
        'ReadWriteOnce',
      ],
      resources: {
        requests: {
          storage: '24Gi',
        },
      },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'photoprism-storage',
    },
    spec: {
      storageClassName: 'longhorn',
      volumeName: 'photoprism-storage',
      accessModes: [
        'ReadWriteOnce',
      ],
      resources: {
        requests: {
          storage: '4Gi',
        },
      },
    },
  },
]
