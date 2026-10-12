local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local name = app.name + '-api';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: name,
    namespace: app.namespace,
    labels: labels(name),
  },
  spec: {
    ports: [{ name: 'http', port: 8080, targetPort: 8080 }],
    selector: labels(name),
    type: 'ClusterIP',
  },
}
