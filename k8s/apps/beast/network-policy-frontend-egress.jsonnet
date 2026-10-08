local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: { name: app.name + '-frontend-egress', namespace: app.namespace },
  spec: {
    podSelector: { matchLabels: { 'app.kubernetes.io/name': 'frontend' } },
    policyTypes: ['Egress'],
    egress: [{
      to: [{ podSelector: { matchLabels: { 'app.kubernetes.io/name': 'backend' } } }],
      ports: [{ protocol: 'TCP', port: 8080 }],
    }],
  },
}
