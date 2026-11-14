local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: app.name + '-learning-job',
    namespace: app.namespace,
  },
  automountServiceAccountToken: true,
}
