local app = import 'app.json5';

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
      toPorts: [{ ports: [{ port: '80', protocol: 'TCP' }] }],
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
        ] }],
      },
      {
        toEntities: ['world'],
        toPorts: [{ ports: [{ port: '443', protocol: 'TCP' }] }],
      },
    ],
  },
}
