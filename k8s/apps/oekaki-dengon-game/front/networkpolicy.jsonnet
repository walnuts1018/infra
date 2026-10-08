local labels = import '../../../components/labels.libsonnet';
local networkPolicy = import '../../../components/network-policy.libsonnet';
local app = import '../app.json5';

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
    policyTypes: ['Ingress', 'Egress'],
    ingress: [{
      from: [networkPolicy.envoyGatewayProxy],
      ports: [{ protocol: 'TCP', port: 3000 }],
    }],
    egress: [
      {
        to: [
          networkPolicy.otelDefaultCollector,
        ],
        ports: [
          { protocol: 'TCP', port: 4317 },
          { protocol: 'TCP', port: 4318 },
        ],
      },
      {
        to: [
          {
            podSelector: {
              matchLabels: labels(app.name + '-back'),
            },
          },
        ],
        ports: [{ protocol: 'TCP', port: 8080 }],
      },
      {
        to: [networkPolicy.kubeDns],
        ports: [
          { protocol: 'UDP', port: 53 },
          { protocol: 'TCP', port: 53 },
        ],
      },
    ],
  },
}
