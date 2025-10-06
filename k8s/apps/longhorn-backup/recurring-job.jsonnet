{
  apiVersion: 'longhorn.io/v1beta2',
  kind: 'RecurringJob',
  metadata: {
    name: 'minio-biscuit-backup',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    concurrency: 1,
    cron: '10 17 * * ?',  // AM 2:10
    groups: [
      'default',
    ],
    labels: {
      automated: 'true',
    },
    name: 'minio-biscuit-backup',
    retain: 5,
    task: 'backup',
  },
}
