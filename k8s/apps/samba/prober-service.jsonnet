local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'samba-prober',
    namespace: app.namespace,
    labels: labels('samba-prober'),
  },
  spec: {
    ports: [
      {
        name: 'metrics',
        port: 9187,
        protocol: 'TCP',
        targetPort: 'metrics',
      },
    ],
    selector: labels('samba-prober'),
    type: 'ClusterIP',
  },
}
