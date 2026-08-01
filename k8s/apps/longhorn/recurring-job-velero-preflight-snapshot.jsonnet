{
  apiVersion: 'longhorn.io/v1beta2',
  kind: 'RecurringJob',
  metadata: {
    name: 'snapshot',
    namespace: 'longhorn-system',
  },
  spec: {
    concurrency: 1,
    cron: '30 16 * * ?',
    groups: ['default'],
    name: 'snapshot',
    parameters: {},
    retain: 2,
    task: 'snapshot',
  },
}
