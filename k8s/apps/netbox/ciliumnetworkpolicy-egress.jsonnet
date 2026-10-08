local app = import 'app.json5';

{
  apiVersion: 'cilium.io/v2',
  kind: 'CiliumNetworkPolicy',
  metadata: {
    name: app.name + '-egress',
    namespace: app.namespace,
  },
  spec: {
    endpointSelector: {
      matchLabels: {
        'k8s:app.kubernetes.io/instance': app.name,
        'k8s:app.kubernetes.io/name': app.name,
      },
    },
    egress: [
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'kube-system',
            'k8s:k8s-app': 'kube-dns',
          },
        }],
        toPorts: [{
          ports: [
            { port: '53', protocol: 'UDP' },
            { port: '53', protocol: 'TCP' },
          ],
        }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'databases',
            'k8s:cnpg.io/cluster': 'postgresql-default',
            'k8s:cnpg.io/instanceRole': 'primary',
          },
        }],
        toPorts: [{ ports: [{ port: '5432', protocol: 'TCP' }] }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': app.namespace,
            'k8s:app.kubernetes.io/instance': app.name,
            'k8s:app.kubernetes.io/name': 'valkey',
          },
        }],
        toPorts: [{ ports: [{ port: '6379', protocol: 'TCP' }] }],
      },
      {
        toEntities: ['world'],
        toPorts: [{
          ports: [
            { port: '443', protocol: 'TCP' },
            { port: '587', protocol: 'TCP' },
          ],
        }],
      },
      {
        toEndpoints: [{
          matchLabels: {
            'k8s:io.kubernetes.pod.namespace': 'envoy-gateway-system',
            'k8s:app.kubernetes.io/component': 'proxy',
            'k8s:app.kubernetes.io/managed-by': 'envoy-gateway',
            'k8s:app.kubernetes.io/name': 'envoy',
            'k8s:gateway.envoyproxy.io/owning-gateway-name': 'envoy-gateway',
            'k8s:gateway.envoyproxy.io/owning-gateway-namespace': 'envoy-gateway-system',
          },
        }],
        toPorts: [{ ports: [{ port: '10443', protocol: 'TCP' }] }],
      },
    ],
  },
}
