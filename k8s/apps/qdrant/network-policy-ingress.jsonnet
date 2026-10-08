local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
local qdrantPods = {
  matchLabels: {
    'app.kubernetes.io/instance': app.name,
    'app.kubernetes.io/name': app.name,
  },
};

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: qdrantPods.matchLabels,
    },
    policyTypes: ['Ingress'],
    ingress: [
      {
        from: [{
          namespaceSelector: {
            matchLabels: {
              'kubernetes.io/metadata.name': 'picca',
            },
          },
          podSelector: {
            matchExpressions: [{
              key: 'app.kubernetes.io/name',
              operator: 'In',
              values: [
                'picca-apiserver',
                'picca-embedding-worker',
                'picca-index-commit-worker',
              ],
            }],
          },
        }],
        ports: [{ protocol: 'TCP', port: 6334 }],
      },
      {
        from: [networkPolicy.otelPrometheusCollector],
        ports: [{ protocol: 'TCP', port: 6333 }],
      },
      {
        from: [{ podSelector: qdrantPods }],
        ports: [
          { protocol: 'TCP', port: 6333 },
          { protocol: 'TCP', port: 6334 },
          { protocol: 'TCP', port: 6335 },
        ],
      },
    ],
  },
}
