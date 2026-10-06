local app = import 'app.json5';

// TODO: 消したい
// StatefulSetのvolumeClaimTemplatesは作成後にサイズ変更できないため、ordinal 0の既存claim容量をこのmanifestで管理する。
{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'data-' + app.name + '-volume-hdd-0',
    namespace: app.namespace,
  },
  spec: {
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '320Gi',
      },
    },
    storageClassName: 'topolvm-hdd',
    volumeMode: 'Filesystem',
  },
}
