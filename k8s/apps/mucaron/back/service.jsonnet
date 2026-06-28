local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  kind: 'Service',
  apiVersion: 'v1',
  metadata: {
    name: app.name + '-back',
    namespace: app.namespace,
    labels: (labels)(app.name + '-back'),
  },
  spec: {
    selector: (labels)(app.name + '-back'),
    ports: [
      {
        protocol: 'TCP',
        port: 8080,
        targetPort: 8080,
      },
    ],
    type: 'ClusterIP',
  },
}
