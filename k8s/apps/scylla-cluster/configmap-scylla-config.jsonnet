local configmap = import '../../components/configmap.libsonnet';
local app = import 'app.json5';
local scylla = importstr './_configs/scylla.yaml';
(configmap) {
  name: 'scylla-config',
  namespace: app.namespace,
  data: {
    'scylla.yaml': (scylla),
  },
}
