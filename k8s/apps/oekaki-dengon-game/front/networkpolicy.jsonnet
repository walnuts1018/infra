local app = import '../app.json5';
local labels = import '../../../components/labels.libsonnet';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-front',
    namespace: app.namespace,
    labels: labels(app.name + '-front'),
  },
  spec: {
    podSelector: {
      matchLabels: labels(app.name + '-front'),
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
            podSelector: {
              matchLabels: labels(app.name + '-back'),
            },
          },
        ],
      },
    ],
  },
}
