local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-config',
  namespace: app.namespace,
  labels: labels(app.name),
  data: {
    'config.json': (importstr '_config/config.json'),
  },
}
