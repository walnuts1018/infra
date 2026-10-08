local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';

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
    name: 'akvorado-console-egress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/component': 'console',
        'app.kubernetes.io/name': app.name,
      },
    },
    policyTypes: ['Egress'],
    egress: [
      {
        to: [networkPolicy.kubeDns],
        ports: [
          { protocol: 'UDP', port: 53 },
          { protocol: 'TCP', port: 53 },
        ],
      },
      {
        to: [sameNamespace {
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/name': 'clickhouse-server',
              'clickhouse.com/cluster': 'akvorado-clickhouse',
              'clickhouse.com/role': 'clickhouse-server',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 9000 }],
      },
      {
        to: [sameNamespace {
          podSelector: {
            matchLabels: {
              'app.kubernetes.io/component': 'orchestrator',
              'app.kubernetes.io/name': app.name,
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 8080 }],
      },
      {
        to: [sameNamespace {
          podSelector: {
            matchLabels: {
              'valkey.io/cluster': 'akvorado-valkey',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 6379 }],
      },
    ],
  },
}
