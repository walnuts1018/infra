local app = import 'app.json5';
local labels = (import '../../components/labels.libsonnet')(app.name + '-blackbox');
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: { name: app.name + '-blackbox', namespace: app.namespace, labels: labels },
  spec: { selector: labels, ports: [{ name: 'http', port: 9115, targetPort: 'http' }] },
}
