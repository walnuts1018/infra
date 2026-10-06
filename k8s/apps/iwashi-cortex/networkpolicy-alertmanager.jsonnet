local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-alertmanager',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/name': 'cortex',
        'app.kubernetes.io/instance': app.name,
        'app.kubernetes.io/component': 'alertmanager',
      },
    },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [{
      from: [
        {
          podSelector: { matchLabels: { 'app.kubernetes.io/name': 'iwashi' } },
        },
      ],
      ports: [{ port: 8080, protocol: 'TCP' }],
    }],
    egress: [{
      to: [{
        namespaceSelector: {
          matchLabels: { 'kubernetes.io/metadata.name': 'kube-system' },
        },
        podSelector: { matchLabels: { 'k8s-app': 'kube-dns' } },
      }],
      ports: [
        { port: 53, protocol: 'UDP' },
        { port: 53, protocol: 'TCP' },
      ],
    }, {
      to: [{
        podSelector: {
          matchLabels: {
            'app.kubernetes.io/name': 'mail',
            'app.kubernetes.io/instance': 'iwashi-smtp-relay',
          },
        },
      }],
      ports: [{ port: 587, protocol: 'TCP' }],
    }],
  },
}
