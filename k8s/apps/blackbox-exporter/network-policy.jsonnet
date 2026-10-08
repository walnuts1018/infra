local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: { name: app.name, namespace: app.namespace },
  spec: {
    podSelector: { matchLabels: {
      'app.kubernetes.io/name': 'prometheus-blackbox-exporter',
      'app.kubernetes.io/instance': app.name,
    } },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [{
      from: [
        { namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'monitoring' } } },
      ],
      ports: [{ protocol: 'TCP', port: 9115 }],
    }],
    egress: [
      {
        to: [networkPolicy.kubeDns],
        ports: [{ protocol: 'UDP', port: 53 }, { protocol: 'TCP', port: 53 }],
      },
      {
        to: networkPolicy.publicInternet,
        ports: [{ protocol: 'TCP', port: 80 }, { protocol: 'TCP', port: 443 }],
      },
    ],
  },
}
