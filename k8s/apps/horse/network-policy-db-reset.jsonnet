local labels = import '../../components/labels.libsonnet';
local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';
local name = app.name + '-db-reset';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: name + '-network',
    namespace: app.namespace,
    annotations: { 'argocd.argoproj.io/sync-wave': '-2' },
  },
  spec: {
    podSelector: { matchLabels: labels(name) },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [],
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
    ],
  },
}
