local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: { name: app.name + '-stun', namespace: app.namespace },
  spec: {
    type: 'LoadBalancer',
    loadBalancerIP: '192.168.0.142',
    selector: labels(app.name + '-server'),
    ports: [{
      name: 'stun',
      port: 3478,
      targetPort: 3478,
      protocol: 'UDP',
    }],
  },
}
