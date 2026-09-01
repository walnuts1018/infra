local app = import 'app.json5';

local config = importstr './_configs/envoy.yaml';

(import '../../components/configmap.libsonnet') {
  name: app.name + '-envoy-config',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name + '-versatiles-server'),
  data: {
    'envoy.yaml': config,
  },
}
