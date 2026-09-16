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
        { namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'iwashi' } } },
      ],
      ports: [{ protocol: 'TCP', port: 9115 }],
    }],
    egress: [
      {
        to: [{ namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'kube-system' } }, podSelector: { matchLabels: { 'k8s-app': 'kube-dns' } } }],
        ports: [{ protocol: 'UDP', port: 53 }, { protocol: 'TCP', port: 53 }],
      },
      {
        to: [{ ipBlock: { cidr: '0.0.0.0/0', except: [
          '0.0.0.0/8',
          '10.0.0.0/8',
          '100.64.0.0/10',
          '127.0.0.0/8',
          '169.254.0.0/16',
          '172.16.0.0/12',
          '192.0.0.0/24',
          '192.0.2.0/24',
          '192.168.0.0/16',
          '198.18.0.0/15',
          '198.51.100.0/24',
          '203.0.113.0/24',
          '224.0.0.0/4',
          '240.0.0.0/4',
        ] } }],
        ports: [{ protocol: 'TCP', port: 80 }, { protocol: 'TCP', port: 443 }],
      },
    ],
  },
}
