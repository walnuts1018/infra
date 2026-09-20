local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: app.name + '-runner-vod-config',
    namespace: app.namespace,
  },
  data: {
    'config.toml': importstr './_config/runner-config.toml',
  },
}
