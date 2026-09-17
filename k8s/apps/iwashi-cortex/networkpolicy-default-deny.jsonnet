local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-default-deny',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {},
    policyTypes: ['Ingress', 'Egress'],
  },
}
