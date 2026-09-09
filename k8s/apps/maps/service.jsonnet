local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-versatiles-server',
    namespace: app.namespace,
    labels: labels(app.name + '-versatiles-server'),
  },
  spec: {
    selector: labels(app.name + '-versatiles-server'),
    ports: [
      { name: 'http', port: 80, targetPort: 8080 },
    ],
    type: 'ClusterIP',
  },
}
