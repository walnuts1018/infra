local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-dense-service',
    namespace: app.namespace,
    labels: labels(app.name + '-dense-service'),
  },
  spec: {
    selector: labels(app.name + '-dense-service'),
    ports: [
      { name: 'http', port: 8001, targetPort: 'http' },
    ],
    type: 'ClusterIP',
  },
}
