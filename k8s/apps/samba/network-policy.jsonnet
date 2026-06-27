local labels = import '../../components/labels.libsonnet';
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
      matchLabels: labels(app.name),
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
