local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: app.name + '-config',
    namespace: app.namespace,
  },
  data: {
    'production.yaml': (importstr './_config/production.yaml'),
  },
}
