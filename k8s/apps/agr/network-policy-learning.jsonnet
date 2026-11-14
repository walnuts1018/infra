local labels = import '../../components/labels.libsonnet';
local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-learning',
    namespace: app.namespace,
  },
  spec: {
    podSelector: { matchLabels: labels(app.name + '-learning') },
    policyTypes: ['Egress'],
    egress: [
      {
        to: [networkPolicy.kubeDns],
        ports: [{ protocol: 'UDP', port: 53 }, { protocol: 'TCP', port: 53 }],
      },
      {
        to: [{ podSelector: { matchLabels: labels(app.name + '-server') } }],
        ports: [{ protocol: 'TCP', port: 8080 }, { protocol: 'TCP', port: 8081 }],
      },
      {
        to: [{
          namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'seaweedfs' } },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/component': 's3',
              'app.kubernetes.io/instance': 'seaweedfs-default',
              'app.kubernetes.io/name': 'seaweedfs',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 8333 }],
      },
    ],
  },
}
