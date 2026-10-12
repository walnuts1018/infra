local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local name = app.name + '-web';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: name,
    namespace: app.namespace,
    labels: labels(name),
  },
  spec: {
    ports: [{ name: 'http', port: 3000, targetPort: 3000 }],
    selector: labels(name),
    type: 'ClusterIP',
  },
}
