local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local config = importstr './_configs/config.js';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-config',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    'config.js': (config),
  },
}
