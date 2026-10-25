local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: { name: app.name, namespace: app.namespace },
  spec: {
    podSelector: { matchLabels: {
      'app.kubernetes.io/name': 'prometheus-blackbox-exporter',
      'app.kubernetes.io/instance': app.name,
    } },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [{
      from: [networkPolicy.otelPrometheusCollector],
      ports: [{ protocol: 'TCP', port: 9115 }],
    }],
    egress: [
      {
        to: [networkPolicy.envoyGatewayProxy],
        ports: [{ protocol: 'TCP', port: 10025 }, { protocol: 'TCP', port: 10993 }],
      },
      {
        to: [networkPolicy.kubeDns],
        ports: [{ protocol: 'UDP', port: 53 }, { protocol: 'TCP', port: 53 }],
      },
      {
        to: [{
          namespaceSelector: {
            matchLabels: { 'kubernetes.io/metadata.name': 'mcl-website' },
          },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/instance': 'mcl-playground-api',
              'app.kubernetes.io/name': 'mcl-playground-api',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 8080 }],
      },
      {
        to: networkPolicy.publicInternet,
        ports: [{ protocol: 'TCP', port: 80 }, { protocol: 'TCP', port: 443 }],
      },
    ],
  },
}
