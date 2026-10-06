local app = import 'app.json5';
local cortexSelector = {
  matchLabels: {
    'app.kubernetes.io/name': 'cortex',
    'app.kubernetes.io/instance': app.name,
  },
};
local prometheusCollector = {
  namespaceSelector: {
    matchLabels: { 'kubernetes.io/metadata.name': 'opentelemetry-collector' },
  },
  podSelector: {
    matchLabels: {
      'app.kubernetes.io/component': 'opentelemetry-collector',
      'app.kubernetes.io/instance': 'opentelemetry-collector.prometheus',
    },
  },
};
local dns = {
  to: [{
    namespaceSelector: {
      matchLabels: { 'kubernetes.io/metadata.name': 'kube-system' },
    },
    podSelector: { matchLabels: { 'k8s-app': 'kube-dns' } },
  }],
  ports: [
    { port: 53, protocol: 'UDP' },
    { port: 53, protocol: 'TCP' },
  ],
};
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-internal',
    namespace: app.namespace,
  },
  spec: {
    podSelector: cortexSelector,
    policyTypes: ['Ingress', 'Egress'],
    ingress: [
      {
        from: [{ podSelector: cortexSelector }],
        ports: [
          { port: 8080, protocol: 'TCP' },
          { port: 9095, protocol: 'TCP' },
          { port: 7946, protocol: 'TCP' },
          { port: 9094, protocol: 'TCP' },
        ],
      },
      {
        from: [prometheusCollector],
        ports: [{ port: 8080, protocol: 'TCP' }],
      },
    ],
    egress: [
      {
        to: [{ podSelector: cortexSelector }],
        ports: [
          { port: 8080, protocol: 'TCP' },
          { port: 9095, protocol: 'TCP' },
          { port: 7946, protocol: 'TCP' },
          { port: 9094, protocol: 'TCP' },
        ],
      },
      {
        to: [{
          podSelector: {
            matchLabels: { 'app.kubernetes.io/instance': app.name },
            matchExpressions: [{
              key: 'app.kubernetes.io/name',
              operator: 'In',
              values: [
                'memcached-frontend',
                'memcached-blocks-index',
                'memcached-blocks',
                'memcached-blocks-metadata',
              ],
            }],
          },
        }],
        ports: [{ port: 11211, protocol: 'TCP' }],
      },
      {
        to: [{
          namespaceSelector: {
            matchLabels: { 'kubernetes.io/metadata.name': 'envoy-gateway-system' },
          },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/component': 'proxy',
              'app.kubernetes.io/name': 'envoy',
            },
          },
        }],
        ports: [{ port: 10443, protocol: 'TCP' }],
      },
      dns,
    ],
  },
}
