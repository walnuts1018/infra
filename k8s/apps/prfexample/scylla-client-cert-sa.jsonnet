local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: 'prfexample-scylla-secret-reader',
    namespace: app.namespace,
  },
}
