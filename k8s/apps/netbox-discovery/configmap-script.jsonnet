local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-script',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    'snmp-discovery.sh': (importstr './_scripts/snmp-discovery.sh'),
  },
}
