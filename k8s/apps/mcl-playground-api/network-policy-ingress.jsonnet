local labels = import '../../components/labels.libsonnet';
local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: { matchLabels: labels(app.name) },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [
        networkPolicy.envoyGatewayProxy,
        {
          namespaceSelector: {
            matchLabels: { 'kubernetes.io/metadata.name': 'monitoring' },
          },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/instance': 'blackbox-exporter',
              'app.kubernetes.io/name': 'prometheus-blackbox-exporter',
            },
          },
        },
      ],
      ports: [{ protocol: 'TCP', port: 8080 }],
    }],
  },
}
