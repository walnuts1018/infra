{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'talos-image-1-11-5',
    namespace: (import 'app.json5').namespace,  // TODO
    annotations: {
      // customization:
      //     systemExtensions:
      //         officialExtensions:
      //             - siderolabs/iscsi-tools
      //             - siderolabs/util-linux-tools
      'cdi.kubevirt.io/storage.import.endpoint': 'https://factory.talos.dev/image/613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245/v1.11.5/openstack-amd64.raw.xz',
    },
  },
  spec: {
    storageClassName: 'longhorn-local',
    volumeMode: 'Block',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '16Gi',
      },
    },
  },
}
