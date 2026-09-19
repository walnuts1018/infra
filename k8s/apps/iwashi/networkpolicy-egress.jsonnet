local app = import 'app.json5';
local dns = {
  to: [{
    namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'kube-system' } },
    podSelector: { matchLabels: { 'k8s-app': 'kube-dns' } },
  }],
  ports: [
    { port: 53, protocol: 'UDP' },
    { port: 53, protocol: 'TCP' },
  ],
};
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: { name: app.name + '-egress', namespace: app.namespace },
  spec: {
    podSelector: { matchLabels: { 'app.kubernetes.io/name': app.name } },
    policyTypes: ['Egress'],
    egress: [
      dns,
      {
        to: [{
          namespaceSelector: { matchLabels: { 'kubernetes.io/metadata.name': 'databases' } },
          podSelector: { matchLabels: { 'cnpg.io/cluster': 'postgresql-default', 'cnpg.io/instanceRole': 'primary' } },
        }],
        ports: [{ port: 5432, protocol: 'TCP' }],
      },
      {
        to: [{
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/name': 'cortex',
              'app.kubernetes.io/instance': 'iwashi-cortex',
            },
            matchExpressions: [{
              key: 'app.kubernetes.io/component',
              operator: 'In',
              values: ['alertmanager', 'distributor', 'querier', 'ruler'],
            }],
          },
        }],
        ports: [{ port: 8080, protocol: 'TCP' }],
      },
    ],
  },
}
