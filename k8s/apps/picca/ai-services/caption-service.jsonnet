local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-caption-service',
    namespace: app.namespace,
    labels: labels(app.name + '-caption-service'),
  },
  spec: {
    selector: labels(app.name + '-caption-service'),
    ports: [
      { name: 'http', port: 8004, targetPort: 'http' },
    ],
    type: 'ClusterIP',
  },
}
