local app = import 'app.json5';
local apiFqdn = 'api.github.com';

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'k8s:app.kubernetes.io/name': app.name,
        'k8s:app': app.name,
      },
    },
    ingress: [{
      fromEndpoints: [{
        matchLabels: {
          'k8s:io.kubernetes.pod.namespace': 'envoy-gateway-system',
          'k8s:app.kubernetes.io/component': 'proxy',
          'k8s:app.kubernetes.io/managed-by': 'envoy-gateway',
          'k8s:app.kubernetes.io/name': 'envoy',
        },
      }],
      toPorts: [{ ports: [{ port: '9000', protocol: 'TCP' }] }],
    }],
    egress: [
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'kube-system',
            'k8s:k8s-app': 'kube-dns',
          },
        }],
        toPorts: [{ ports: [
          { port: '53', protocol: 'UDP' },
          { port: '53', protocol: 'TCP' },
        ], rules: { dns: [{ matchName: apiFqdn }] } }],
      },
      {
        toFQDNs: [{ matchName: apiFqdn }],
        toPorts: [{ ports: [{ port: '443', protocol: 'TCP' }] }],
      },
    ],
  },
}
