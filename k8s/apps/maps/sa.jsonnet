local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: app.name + '-versatiles-server',
    namespace: app.namespace,
  },
  automountServiceAccountToken: false,
}
