local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local name = app.name + '-ocr';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: name,
    namespace: app.namespace,
    labels: labels(name),
  },
  spec: {
    selector: labels(name),
    ports: [{ name: 'http', port: 8000, targetPort: 'http' }],
  },
}
