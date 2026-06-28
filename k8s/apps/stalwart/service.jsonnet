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
    selector: (labels)(app.name),
    ports: [
      {
        name: 'http',
        protocol: 'TCP',
        port: 8080,
        targetPort: 'http',
      },
      {
        name: 'https',
        protocol: 'TCP',
        port: 443,
        targetPort: 'https',
      },
      {
        name: 'smtp',
        protocol: 'TCP',
        port: 25,
        targetPort: 'smtp',
      },
      {
        name: 'smtps',
        protocol: 'TCP',
        port: 465,
        targetPort: 'smtps',
      },
      {
        name: 'imaps',
        protocol: 'TCP',
        port: 993,
        targetPort: 'imaps',
      },
    ],
    type: 'ClusterIP',
  },
}
