local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-web',
    namespace: app.namespace,
    labels: labels(app.name + '-web'),
  },
  spec: {
    type: 'ClusterIP',
    selector: labels(app.name + '-web'),
    ports: [
      { name: 'http', port: 3000, targetPort: 3000, protocol: 'TCP' },
    ],
  },
}
