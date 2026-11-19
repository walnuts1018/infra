local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: app.name + '-bootstrap',
    namespace: app.namespace,
  },
  data: {
    'bootstrap.py': importstr '_scripts/bootstrap.py',
  },
}
