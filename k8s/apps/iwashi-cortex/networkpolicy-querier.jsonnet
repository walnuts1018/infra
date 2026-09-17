local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-querier',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/name': 'cortex',
        'app.kubernetes.io/instance': app.name,
        'app.kubernetes.io/component': 'querier',
      },
    },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [
        {
          namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'monitoring-app' } },
          podSelector: { matchLabels: { 'app.kubernetes.io/name': 'iwashi' } },
        },
      ],
      ports: [{ port: 8080, protocol: 'TCP' }],
    }],
  },
}
