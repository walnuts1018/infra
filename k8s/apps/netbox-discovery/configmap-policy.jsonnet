{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: (import 'app.json5').name + '-policy',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  data: {
    'snmp-policy.yaml': (importstr './_config/snmp-policy.yaml'),
  },
}
