local networkPolicy = import '../../../components/network-policy.libsonnet';

local app = import '../app.json5';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: 'vyos-collector-egress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/component': 'opentelemetry-collector',
        'app.kubernetes.io/instance': app.namespace + '.vyos',
      },
    },
    policyTypes: ['Egress'],
    egress: [
      {
        to: [networkPolicy.kubeDns],
        ports: [
          { protocol: 'UDP', port: 53 },
          { protocol: 'TCP', port: 53 },
        ],
      },
      {
        to: [{
          ipBlock: {
            cidr: '192.168.0.1/32',
          },
        }],
        ports: [{ protocol: 'TCP', port: 9273 }],
      },
      {
        to: [{
          namespaceSelector: {
            matchLabels: {
              'kubernetes.io/metadata.name': 'victoria-metrics',
            },
          },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/component': 'vminsert',
              'app.kubernetes.io/instance': 'victoria-metrics',
              'app.kubernetes.io/name': 'victoria-metrics-cluster',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 8480 }],
      },
      {
        to: [{
          namespaceSelector: {
            matchLabels: {
              'kubernetes.io/metadata.name': 'loki',
            },
          },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/component': 'gateway',
              'app.kubernetes.io/instance': 'loki',
              'app.kubernetes.io/name': 'loki',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 8080 }],
      },
    ],
  },
}
