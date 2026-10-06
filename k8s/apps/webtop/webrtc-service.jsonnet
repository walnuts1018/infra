local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-webrtc',
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    type: 'LoadBalancer',
    loadBalancerIP: '192.168.12.143',
    selector: labels(app.name),
    ports: [
      {
        name: 'webrtc',
        protocol: 'UDP',
        port: 59000,
        targetPort: 'webrtc',
      },
    ],
  },
}
