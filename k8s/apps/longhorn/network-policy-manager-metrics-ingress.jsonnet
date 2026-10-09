local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-manager-metrics-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        app: 'longhorn-manager',
      },
    },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [networkPolicy.otelPrometheusCollector],
      ports: [{ protocol: 'TCP', port: 9500 }],
    }],
  },
}
