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
      pods: '2',
      'count/deployments.apps': '2',
      persistentvolumeclaims: '2',
      'requests.storage': '256Gi',
      'requests.cpu': '2',
      'requests.memory': '4Gi',
      'limits.cpu': '16',
      'limits.memory': '32Gi',
    },
  },
}
