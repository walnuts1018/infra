local app = import '../app.json5';
local labels = import '../../../components/labels.libsonnet';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-back',
    namespace: app.namespace,
    labels: labels(app.name + '-back'),
  },
  spec: {
    podSelector: {
      matchLabels: labels(app.name + '-back'),
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
                'cnpg.io/cluster': 'postgresql-default',
              },
            },
          },
        ],
      },
    ],
  },
}
