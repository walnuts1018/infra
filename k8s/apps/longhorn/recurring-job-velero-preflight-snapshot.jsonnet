// veleroによるs3バックアップ実行時にもSnapshotが作られるけど、Backup実行時に作られるSnapshotはバックアップに失敗した時に`ReadyToUse: false`になってしまう
// そこで、それよりも前にSnapshotをRecurringJobで作っておく
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
