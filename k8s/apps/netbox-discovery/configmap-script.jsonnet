(import '../../components/configmap.libsonnet') {
  name: (import 'app.json5').name + '-script',
  namespace: (import 'app.json5').namespace,
  labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  data: {
    'snmp-discovery.sh': (importstr './_scripts/snmp-discovery.sh'),
  },
}
