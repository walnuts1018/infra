local configmap = import '../../components/configmap.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local config = importstr './_configs/config.js';
(configmap) {
  name: app.name + '-config',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    'config.js': (config),
  },
}
