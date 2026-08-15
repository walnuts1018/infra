local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: 'walnuk-scylla-secret-reader',
    namespace: app.namespace,
  },
}
