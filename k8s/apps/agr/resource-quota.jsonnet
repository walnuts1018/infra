local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'ResourceQuota',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    hard: {
      pods: '20',
      'requests.cpu': '8',
      'requests.memory': '16Gi',
      'limits.cpu': '16',
      'limits.memory': '32Gi',
      'count/deployments.apps': '4',
      'count/horizontalpodautoscalers.autoscaling': '4',
    },
  },
}
