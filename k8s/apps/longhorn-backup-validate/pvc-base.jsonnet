{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'talos-image-1-11-5',
    annotations: {
      'cdi.kubevirt.io/storage.import.endpoint': 'https://factory.talos.dev/image/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba/v1.11.5/openstack-amd64.raw.xz',
    },
  },
  spec: {
    storageClassName: 'longhorn',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '6Gi',
      },
    },
  },
}
