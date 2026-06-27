local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local config = importstr './config/config.yaml';
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: app.name + '-config',
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  data: {
    'config.yaml': (config),
  },
}
