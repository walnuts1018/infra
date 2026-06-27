local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  kind: 'Service',
  apiVersion: 'v1',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    selector: (labels)(app.name),
    ports: [
      {
        protocol: 'TCP',
        port: 80,
        targetPort: 9000,
      },
    ],
    type: 'ClusterIP',
  },
}
