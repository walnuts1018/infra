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
        port: 445,
        protocol: 'TCP',
        targetPort: 10445,
      },
    ],
    selector: (labels)(app.name),
    type: 'LoadBalancer',
    loadBalancerIP: '192.168.0.132',
  },
}
