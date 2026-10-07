local app = import 'app.json5';
local valkeyLabels = (import '../../components/labels.libsonnet')(app.name + '-valkey') + {
  'app.kubernetes.io/instance': app.name,
};
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-valkey',
    namespace: app.namespace,
    labels: valkeyLabels,
  },
  spec: {
    type: 'ClusterIP',
    selector: valkeyLabels,
    ports: [
      {
        name: 'valkey',
        port: 6379,
        targetPort: 'valkey',
        protocol: 'TCP',
      },
    ],
  },
}
