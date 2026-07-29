local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    type: 'ClusterIP',
    ports: [
      {
        name: 'http',
        port: 8080,
        targetPort: 'http',
        protocol: 'TCP',
      },
    ],
    selector: labels(app.name),
  },
}
