local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-imgproxy',
    namespace: app.namespace,
    labels: labels(app.name + '-imgproxy'),
  },
  spec: {
    selector: labels(app.name + '-imgproxy'),
    ports: [
      {
        name: 'http',
        port: 80,
        targetPort: 8080,
      },
      {
        name: 'metrics',
        port: 8081,
        targetPort: 8081,
      },
    ],
    type: 'ClusterIP',
  },
}
