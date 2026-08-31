local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local valkeyLabels = labels(app.name + '-valkey');
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-valkey',
    namespace: app.namespace,
    labels: valkeyLabels,
  },
  spec: {
    selector: valkeyLabels,
    ports: [
      {
        name: 'valkey',
        port: 6379,
        targetPort: 'valkey',
      },
    ],
  },
}
