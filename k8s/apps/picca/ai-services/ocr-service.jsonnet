local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-ocr-service',
    namespace: app.namespace,
    labels: labels(app.name + '-ocr-service'),
  },
  spec: {
    selector: labels(app.name + '-ocr-service'),
    ports: [
      { name: 'http', port: 8003, targetPort: 'http' },
    ],
    type: 'ClusterIP',
  },
}
