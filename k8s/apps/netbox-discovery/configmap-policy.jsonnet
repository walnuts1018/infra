local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: app.name + '-policy',
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  data: {
    'snmp-policy.yaml': (importstr './_config/snmp-policy.yaml'),
  },
}
