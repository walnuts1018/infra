local app = import 'app.json5';
local serverLabels = {
  'app.kubernetes.io/name': app.name,
  'app.kubernetes.io/instance': app.name,
  'app.kubernetes.io/component': 'server',
};
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: { matchLabels: serverLabels },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [
        {
          namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'envoy-gateway-system' } },
          podSelector: { matchLabels: { 'app.kubernetes.io/component': 'proxy', 'app.kubernetes.io/name': 'envoy' } },
        },
        {
          podSelector: { matchLabels: { 'app.kubernetes.io/part-of': app.name, 'app.kubernetes.io/component': 'runner' } },
        },
      ],
      ports: [{ port: 9000, protocol: 'TCP' }],
    }],
  },
}
