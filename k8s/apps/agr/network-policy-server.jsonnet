local labels = import '../../components/labels.libsonnet';
local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-server',
    namespace: app.namespace,
  },
  spec: {
    podSelector: { matchLabels: labels(app.name + '-server') },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [
      {
        from: [networkPolicy.envoyGatewayProxy],
        ports: [{ protocol: 'TCP', port: 8080 }],
      },
      {
        from: [{ podSelector: { matchLabels: labels(app.name + '-learning') } }],
        ports: [{ protocol: 'TCP', port: 8080 }, { protocol: 'TCP', port: 8081 }],
      },
    ],
    egress: [
      {
        to: [networkPolicy.kubeDns],
        ports: [{ protocol: 'UDP', port: 53 }, { protocol: 'TCP', port: 53 }],
      },
      {
        to: [{
          namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'databases' } },
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
        to: [networkPolicy.otelDefaultCollector],
        ports: [{ protocol: 'TCP', port: 4317 }],
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
