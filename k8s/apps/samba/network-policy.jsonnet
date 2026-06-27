{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    podSelector: {
      matchLabels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
    },
    policyTypes: [
      'Ingress',
      'Egress',
    ],
    ingress: [
      {
        from: [
          {
            ipBlock: {
              cidr: '192.168.100.0/24',
            },
          },
        ],
        ports: [
          {
            protocol: 'TCP',
            port: 10445,
          },
        ],
      },
    ],
    egress: [
      {
        to: [
          {
            namespaceSelector: {
              matchLabels: {
                'kubernetes.io/metadata.name': 'kube-system',
              },
            },
            podSelector: {
              matchLabels: {
                'k8s-app': 'kube-dns',
              },
            },
          },
        ],
        ports: [
          {
            protocol: 'UDP',
            port: 53,
          },
          {
            protocol: 'TCP',
            port: 53,
          },
        ],
      },
    ],
  },
}
