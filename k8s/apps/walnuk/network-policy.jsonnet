{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    podSelector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    policyTypes: [
      'Egress',
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
          {
            namespaceSelector: {
              matchLabels: {
                'kubernetes.io/metadata.name': 'databases',
              },
            },
            podSelector: {
              matchLabels: {
                'scylla/cluster': 'scylla-cluster',
              },
            },
          },
        ],
      },
    ],
  },
}
