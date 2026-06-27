local configmap = import '../../components/configmap.libsonnet';
local app = import 'app.json5';
local setup = importstr './_scripts/setup.sh';
(configmap) {
  name: 'scylla-setup',
  namespace: app.namespace,
  data: {
    'setup.sh': (setup),
  },
}
