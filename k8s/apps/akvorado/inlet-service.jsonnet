local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'akvorado-inlet',
    namespace: app.namespace,
    labels: labels('akvorado') + {
      'app.kubernetes.io/component': 'inlet',
    },
  },
  spec: {
    selector: {
      'app.kubernetes.io/name': 'akvorado',
      'app.kubernetes.io/component': 'inlet',
    },
    ports: [
      { name: 'http', port: 8080, targetPort: 8080, protocol: 'TCP' },
      { name: 'netflow', port: 2055, targetPort: 2055, protocol: 'UDP' },
      { name: 'sflow', port: 6343, targetPort: 6343, nodePort: 32202, protocol: 'UDP' },
    ],
    type: 'LoadBalancer',
    loadBalancerIP: '192.168.0.140',
    // UDPのNATセッション問題を回避するため
    externalTrafficPolicy: 'Local',
  },
}
