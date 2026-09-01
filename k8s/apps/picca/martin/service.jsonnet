local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-martin',
    namespace: app.namespace,
    labels: labels(app.name + '-martin'),
  },
  spec: {
    selector: labels(app.name + '-martin'),
    ports: [
      { name: 'http', port: 80, targetPort: 3000 },
    ],
    type: 'ClusterIP',
  },
}
