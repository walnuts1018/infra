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
    selector: labels(app.name),
    ports: [
      {
        name: 'http',
        port: 3000,
        targetPort: 'http',
        protocol: 'TCP',
      },
    ],
  },
}
