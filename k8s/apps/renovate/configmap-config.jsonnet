local app = import 'app.json5';
local config = importstr './_configs/config.js';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-config',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name),
  data: {
    'config.js': (config),
  },
}
