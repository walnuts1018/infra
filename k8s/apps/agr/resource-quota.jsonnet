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
      pods: '26',
      'requests.cpu': '11',
      'requests.memory': '20Gi',
      'limits.cpu': '22',
      'limits.memory': '42Gi',
      'count/deployments.apps': '5',
      'count/horizontalpodautoscalers.autoscaling': '5',
    },
  },
}
