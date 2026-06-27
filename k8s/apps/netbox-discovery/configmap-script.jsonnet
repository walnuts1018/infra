local app = import 'app.json5';
(import '../../components/configmap.libsonnet') {
  name: app.name + '-script',
  namespace: app.namespace,
  labels: (import '../../components/labels.libsonnet')(app.name),
  data: {
    'snmp-discovery.sh': (importstr './_scripts/snmp-discovery.sh'),
  },
}
