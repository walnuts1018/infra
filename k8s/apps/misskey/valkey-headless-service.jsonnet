local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local valkeyLabels = labels(app.name + '-valkey');
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-valkey-headless',
    namespace: app.namespace,
    labels: valkeyLabels,
  },
  spec: {
    clusterIP: 'None',
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
