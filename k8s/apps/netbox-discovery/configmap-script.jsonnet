local configmap = import '../../components/configmap.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local snmpDiscovery = importstr './_scripts/snmp-discovery.sh';
(configmap) {
  name: app.name + '-script',
  namespace: app.namespace,
  labels: (labels)(app.name),
  data: {
    'snmp-discovery.sh': (snmpDiscovery),
  },
}
