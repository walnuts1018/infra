{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: std.mergePatch((import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name }, {
      'recurring-job-group.longhorn.io/default': 'enabled',
    }),
  },
  spec: {
    storageClassName: 'longhorn',
    volumeName: 'elasticsearch',
    accessModes: [
      'ReadWriteOnce',
    ],
    resources: {
      requests: {
        storage: '1Gi',
      },
    },
  },
}
