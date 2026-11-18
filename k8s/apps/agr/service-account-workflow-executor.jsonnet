local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: 'agr-workflow-executor',
    namespace: app.namespace,
  },
  automountServiceAccountToken: false,
}
