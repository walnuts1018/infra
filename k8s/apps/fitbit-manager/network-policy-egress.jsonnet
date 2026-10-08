local labels = import '../../components/labels.libsonnet';
local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-egress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: { matchLabels: labels(app.name) },
    policyTypes: ['Egress'],
    egress: [
      {
        to: [networkPolicy.kubeDns],
        ports: [{ protocol: 'UDP', port: 53 }, { protocol: 'TCP', port: 53 }],
      },
      {
        to: [{
          namespaceSelector: {
            matchLabels: { 'kubernetes.io/metadata.name': 'databases' },
          },
          podSelector: {
            matchLabels: {
              'cnpg.io/cluster': 'postgresql-default',
              'cnpg.io/instanceRole': 'primary',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 5432 }],
      },
      {
        to: [{
          namespaceSelector: {
            matchLabels: { 'kubernetes.io/metadata.name': 'databases' },
          },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/instance': 'influxdb',
              'app.kubernetes.io/name': 'influxdb2',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 8086 }],
      },
      {
        to: [networkPolicy.otelDefaultCollector],
        ports: [{ protocol: 'TCP', port: 4317 }],
      },
      {
        to: networkPolicy.publicInternet,
        ports: [{ protocol: 'TCP', port: 443 }],
      },
    ],
  },
}
