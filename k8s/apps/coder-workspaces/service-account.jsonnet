local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: 'coder-workspace',
    namespace: app.namespace,
  },
  automountServiceAccountToken: false,
}
