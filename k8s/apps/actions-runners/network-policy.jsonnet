local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    podSelector: {},
    policyTypes: [
      'Ingress',
      'Egress',
    ],
    ingress: [
      {
        from: [
          {
            namespaceSelector: {
              matchLabels: {
                'kubernetes.io/metadata.name': 'opentelemetry-collector',
              },
            },
          },
        ],
        ports: [
          {
            port: 8080,
            protocol: 'TCP',
          },
        ],
      },
    ],
    egress: [
      {
        to: [
          {
            ipBlock: {
              cidr: '0.0.0.0/0',
              except: [
                '192.168.0.0/16',
                '10.244.0.0/16',
                '10.96.0.0/12',
              ],
            },
          },
        ],
      },
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
            port: 53,
            protocol: 'UDP',
          },
          {
            port: 53,
            protocol: 'TCP',
          },
        ],
      },
      {
        to: [
          {
            namespaceSelector: {
              matchLabels: {
                'kubernetes.io/metadata.name': 'arc-systems',
              },
            },
            podSelector: {
              matchLabels: {
                'app.kubernetes.io/name': 'github-actions-cache-server',
              },
            },
          },
        ],
        ports: [
          {
            port: 3000,
            protocol: 'TCP',
          },
        ],
      },
      {
        to: [
          {
            namespaceSelector: {
              matchLabels: {
                'kubernetes.io/metadata.name': 'opentelemetry-collector',
              },
            },
            podSelector: {
              matchLabels: {
                'app.kubernetes.io/name': 'default-collector',
              },
            },
          },
        ],
        ports: [
          {
            port: 4318,
            protocol: 'TCP',
          },
        ],
      },
    ],
  },
}
