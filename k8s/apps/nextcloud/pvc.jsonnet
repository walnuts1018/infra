[
  {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: (import 'app.json5').name,
      namespace: (import 'app.json5').namespace,
      labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    spec: {
      storageClassName: 'longhorn',
      volumeName: 'nextcloud',
      accessModes: [
        'ReadWriteOnce',
      ],
      resources: {
        requests: {
          storage: '8Gi',
        },
      },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: (import 'app.json5').name + '-data',
      namespace: (import 'app.json5').namespace,
      labels: (import '../../components/labels.libsonnet') + {
        appname: (import 'app.json5').name,
        'recurring-job-group.longhorn.io/default': 'enabled',
      },
    },
    spec: {
      storageClassName: 'longhorn',
      volumeName: 'nextcloud-data',
      accessModes: [
        'ReadWriteOnce',
      ],
      resources: {
        requests: {
          storage: '6Gi',
        },
      },
    },
  },
]
