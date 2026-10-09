local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: 'samba-prober',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: labels('samba-prober'),
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
                'kubernetes.io/metadata.name': 'opentelemetry-collector',
              },
            },
            podSelector: {
              matchLabels: {
                'app.kubernetes.io/name': 'prometheus-collector',
              },
            },
          },
        ],
        ports: [
          {
            protocol: 'TCP',
            port: 9187,
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
                'kubernetes.io/metadata.name': app.namespace,
              },
            },
            podSelector: {
              matchLabels: labels(app.name),
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
