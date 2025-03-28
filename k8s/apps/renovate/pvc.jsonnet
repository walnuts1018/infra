[
  {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: 'renovate',
    },
    spec: {
      storageClassName: 'longhorn',
      accessModes: [
        'ReadWriteOnce',
      ],
      resources: {
        requests: {
          storage: '3Gi',
        },
      },
    },
  },
]
