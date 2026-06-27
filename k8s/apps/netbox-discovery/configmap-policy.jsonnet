local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local snmpPolicy = importstr './_config/snmp-policy.yaml';
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: app.name + '-policy',
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  data: {
    'snmp-policy.yaml': (snmpPolicy),
  },
}
