local labels = import '../../../components/labels.libsonnet';
local networkPolicy = import '../../../components/network-policy.libsonnet';
local app = import '../app.json5';

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
    policyTypes: ['Ingress', 'Egress'],
    ingress: [{
      from: [{ podSelector: { matchLabels: labels(app.name + '-front') } }],
      ports: [{ protocol: 'TCP', port: 8080 }],
    }],
    egress: [
      {
        to: [
          networkPolicy.kubeDns,
        ],
        ports: [
          { protocol: 'UDP', port: 53 },
          { protocol: 'TCP', port: 53 },
        ],
      },
      {
        to: [networkPolicy.otelDefaultCollector],
        ports: [
          { protocol: 'TCP', port: 4317 },
          { protocol: 'TCP', port: 4318 },
        ],
      },
      {
        to: networkPolicy.publicInternet,
        ports: [{ protocol: 'TCP', port: 443 }],
      },
      {
        to: [
          {
            namespaceSelector: {
              matchLabels: {
                'kubernetes.io/metadata.name': 'databases',
              },
            },
            podSelector: {
              matchLabels: {
                'cnpg.io/cluster': 'postgresql-default',
                'cnpg.io/instanceRole': 'primary',
              },
            },
          },
        ],
        ports: [{ protocol: 'TCP', port: 5432 }],
      },
    ],
  },
}
