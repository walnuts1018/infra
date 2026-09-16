local app = import 'app.json5';
local labels = (import '../../components/labels.libsonnet')(app.name + '-alertmanager');
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: { name: app.name + '-alertmanager', namespace: app.namespace, labels: labels },
  spec: { selector: labels, ports: [{ name: 'http', port: 9093, targetPort: 'http' }] },
}
