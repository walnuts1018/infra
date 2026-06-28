local app = import 'app.json5';
local config = importstr './config/config.yaml';
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: app.name + '-config',
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  data: {
    'config.yaml': (config),
  },
}
