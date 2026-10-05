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
        'app.kubernetes.io/name': 'mail',
        'app.kubernetes.io/instance': app.name,
      },
    },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [{
        podSelector: {
          matchLabels: {
            'app.kubernetes.io/name': 'cortex',
            'app.kubernetes.io/instance': 'iwashi-cortex',
            'app.kubernetes.io/component': 'alertmanager',
          },
        },
      }],
      ports: [{ port: 587, protocol: 'TCP' }],
    }],
  },
}
