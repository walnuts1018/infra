local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: 'agr-workflow-executor.service-account-token',
    namespace: app.namespace,
    annotations: {
      'kubernetes.io/service-account.name': 'agr-workflow-executor',
    },
  },
  type: 'kubernetes.io/service-account-token',
}
