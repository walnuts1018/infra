[
  {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'renovate',
    },
    spec: {
      storageClassName: 'longhorn-local',
      volumeName: 'renovate',
      accessModes: [
        'ReadWriteOnce',
      ],
      resources: {
        requests: {
          storage: '20Gi',
        },
      },
    },
  },
]
