{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: 'victoria-metrics-vminsert-egress',
    namespace: 'victoria-metrics',
  },
  spec: {
    podSelector: {
      matchLabels: {
        app: 'vminsert',
        'app.kubernetes.io/name': 'victoria-metrics-cluster',
      },
      matchExpressions: [{
        key: 'app.kubernetes.io/instance',
        operator: 'In',
        values: ['vm-short', 'vm-long'],
      }],
    },
    policyTypes: ['Egress'],
    egress: [
      {
        to: [{
          namespaceSelector: {
            matchLabels: { 'kubernetes.io/metadata.name': 'kube-system' },
          },
          podSelector: {
            matchLabels: { 'k8s-app': 'kube-dns' },
          },
        }],
        ports: [
          { protocol: 'UDP', port: 53 },
          { protocol: 'TCP', port: 53 },
        ],
      },
      {
        to: [{
          podSelector: {
            matchLabels: {
              app: 'vmstorage',
              'app.kubernetes.io/name': 'victoria-metrics-cluster',
            },
            matchExpressions: [{
              key: 'app.kubernetes.io/instance',
              operator: 'In',
              values: ['vm-short', 'vm-long'],
            }],
          },
        }],
        ports: [{ protocol: 'TCP', port: 8400 }],
      },
    ],
  },
}
