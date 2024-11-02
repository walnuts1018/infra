{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: (import 'app.json5').name,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/created-by': 'code-server-operator',
      },
    },
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
                'kubernetes.io/metadata.name': 'ingress-nginx',
              },
            },
            podSelector: {
              matchLabels: {
                'app.kubernetes.io/component': 'controller',
                'app.kubernetes.io/instance': 'ingress-nginx',
                'app.kubernetes.io/name': 'ingress-nginx',
              },
            },
          },
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
      },
    ],
  },
}
