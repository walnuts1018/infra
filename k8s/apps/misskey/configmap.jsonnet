local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local default = importstr './config/default.yml';
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  data: {
    'default.yml': (default),
  },
}
