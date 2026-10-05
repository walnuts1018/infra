local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: { name: app.name + '-api-ingress', namespace: app.namespace },
  spec: {
    podSelector: { matchLabels: { 'app.kubernetes.io/name': 'backend' } },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [
        { namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': app.namespace } } },
        { namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'envoy-gateway-system' } } },
      ],
      ports: [{ protocol: 'TCP', port: 8080 }],
    }],
  },
}
