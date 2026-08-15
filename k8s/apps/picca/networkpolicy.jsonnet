local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    podSelector: {},
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
                'cnpg.io/cluster': 'postgresql-default',
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
          {
            namespaceSelector: {
              matchLabels: {
                'kubernetes.io/metadata.name': 'rabbitmq',
              },
            },
          },
          {
            namespaceSelector: {
              matchLabels: {
                'kubernetes.io/metadata.name': 'seaweedfs',
              },
            },
          },
          {
            namespaceSelector: {
              matchLabels: {
                'kubernetes.io/metadata.name': 'zitadel',
              },
            },
          },
          {
            podSelector: {},
          },
        ],
      },
    ],
  },
}
