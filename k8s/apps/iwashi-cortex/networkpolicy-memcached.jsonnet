local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-memcached',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/instance': app.name,
      },
      matchExpressions: [
        {
          key: 'app.kubernetes.io/name',
          operator: 'In',
          values: [
            'memcached-frontend',
            'memcached-blocks-index',
            'memcached-blocks',
            'memcached-blocks-metadata',
          ],
        },
      ],
    },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [{
      from: [{
        podSelector: {
          matchLabels: {
            'app.kubernetes.io/name': 'cortex',
            'app.kubernetes.io/instance': app.name,
          },
        },
      }],
      ports: [{ port: 11211, protocol: 'TCP' }],
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
    }],
  },
}
