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
      matchLabels: (import '../../components/labels.libsonnet')(app.name),
    },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [
      {
        from: [
          {
            namespaceSelector: {
              matchLabels: { 'kubernetes.io/metadata.name': 'envoy-gateway-system' },
            },
            podSelector: {
              matchLabels: {
                'app.kubernetes.io/component': 'proxy',
                'app.kubernetes.io/managed-by': 'envoy-gateway',
                'app.kubernetes.io/name': 'envoy',
              },
            },
          },
        ],
        ports: [{ protocol: 'TCP', port: 8080 }],
      },
    ],
    egress: [
      {
        to: [
          {
            namespaceSelector: {
              matchLabels: { 'kubernetes.io/metadata.name': 'seaweedfs' },
            },
            podSelector: {
              matchLabels: {
                'app.kubernetes.io/component': 'filer',
                'app.kubernetes.io/instance': 'seaweedfs-default',
                'app.kubernetes.io/managed-by': 'seaweedfs-operator',
                'app.kubernetes.io/name': 'seaweedfs',
              },
            },
          },
        ],
        ports: [{ protocol: 'TCP', port: 8333 }],
      },
      {
        to: [
          {
            namespaceSelector: {
              matchLabels: { 'kubernetes.io/metadata.name': 'kube-system' },
            },
            podSelector: {
              matchLabels: { 'k8s-app': 'kube-dns' },
            },
          },
        ],
        ports: [
          { protocol: 'UDP', port: 53 },
          { protocol: 'TCP', port: 53 },
        ],
      },
    ],
  },
}
