{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'debug-web-data',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-debug-web'),
  },
  spec: {
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
