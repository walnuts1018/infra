local app = import 'app.json5';
local clusterName = 'akvorado-valkey';

local sameNamespace = {
  namespaceSelector: {
    matchLabels: {
      'kubernetes.io/metadata.name': app.namespace,
    },
  },
};

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: 'akvorado-valkey',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'valkey.io/cluster': clusterName,
      },
    },
    policyTypes: ['Ingress', 'Egress'],
    ingress: [
      {
        from: [sameNamespace {
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/component': 'console',
              'app.kubernetes.io/name': app.name,
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 6379 }],
      },
      {
        from: [sameNamespace {
          podSelector: {
            matchLabels: {
              'valkey.io/cluster': clusterName,
            },
          },
        }],
        ports: [
          { protocol: 'TCP', port: 6379 },
          { protocol: 'TCP', port: 16379 },
        ],
      },
      {
        from: [{
          namespaceSelector: {
            matchLabels: {
              'kubernetes.io/metadata.name': 'valkey-operator-system',
            },
          },
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/name': 'valkey-operator',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 6379 }],
      },
    ],
    egress: [{
      to: [sameNamespace {
        podSelector: {
          matchLabels: {
            'valkey.io/cluster': clusterName,
          },
        },
      }],
      ports: [
        { protocol: 'TCP', port: 6379 },
        { protocol: 'TCP', port: 16379 },
      ],
    }],
  },
}
