local labels = import '../../components/labels.libsonnet';
local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
local name = app.name + '-ocr';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: name + '-network',
    namespace: app.namespace,
  },
  spec: {
    podSelector: { matchLabels: labels(name) },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [
      {
        from: [{ podSelector: { matchLabels: labels(app.name + '-worker') } }],
        ports: [{ protocol: 'TCP', port: 8000 }],
      },
    ],
    egress: [
      {
        to: [networkPolicy.kubeDns],
        ports: [{ protocol: 'UDP', port: 53 }, { protocol: 'TCP', port: 53 }],
      },
      {
        to: networkPolicy.publicInternet,
        ports: [{ protocol: 'TCP', port: 443 }],
      },
    ],
  },
}
