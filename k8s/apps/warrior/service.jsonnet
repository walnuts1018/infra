local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 8001,
        protocol: 'TCP',
        targetPort: 'http',
      },
    ],
    selector: (labels)(app.name),
    type: 'ClusterIP',
  },
}
