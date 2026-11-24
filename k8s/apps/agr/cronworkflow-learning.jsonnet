local app = import 'app.json5';
{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'CronWorkflow',
  metadata: {
    name: 'agr-training',
    namespace: app.namespace,
    labels: {
      'workflows.argoproj.io/archive-strategy': 'always',
    },
  },
  spec: {
    schedules: ['*/5 * * * *'],
    timezone: 'Asia/Tokyo',
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 120,
    suspend: true,
    successfulJobsHistoryLimit: 3,
    failedJobsHistoryLimit: 10,
    workflowSpec: {
      workflowTemplateRef: { name: 'agr-learning' },
      arguments: {
        parameters: [
          { name: 'trigger', value: 'cron' },
          { name: 'retry-generation-id', value: '' },
        ],
      },
    },
  },
}
