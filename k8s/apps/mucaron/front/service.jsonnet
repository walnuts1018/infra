local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  kind: 'Service',
  apiVersion: 'v1',
  metadata: {
    name: app.name + '-front',
    namespace: app.namespace,
    labels: (labels)(app.name + '-front'),
  },
  spec: {
    selector: (labels)(app.name + '-front'),
    ports: [
      {
        protocol: 'TCP',
        port: 3000,
        targetPort: 3000,
      },
    ],
    type: 'ClusterIP',
  },
}
