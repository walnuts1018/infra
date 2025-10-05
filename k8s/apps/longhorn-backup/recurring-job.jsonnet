{
  apiVersion: 'longhorn.io/v1beta2',
  kind: 'RecurringJob',
  metadata: {
    name: 'cifs-backup',
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
    name: 'cifs-backup',
    retain: 5,
    task: 'backup',
  },
}
