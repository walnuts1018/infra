local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/instance': app.name,
        'app.kubernetes.io/name': 'prometheus-snmp-exporter',
      },
    },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [
      {
        from: [networkPolicy.otelPrometheusCollector],
        ports: [{ protocol: 'TCP', port: 9116 }],
      },
    ],
    egress: [
      {
        to: [{ ipBlock: { cidr: '192.168.0.1/32' } }],
        ports: [{ protocol: 'UDP', port: 161 }],
      },
    ],
  },
}
