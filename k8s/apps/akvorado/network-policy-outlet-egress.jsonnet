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
    name: 'akvorado-outlet-egress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/component': 'outlet',
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
              'strimzi.io/broker-role': 'true',
              'strimzi.io/cluster': 'akvorado-kafka',
              'strimzi.io/kind': 'Kafka',
              'strimzi.io/name': 'akvorado-kafka-kafka',
            },
          },
        }],
        ports: [{ protocol: 'TCP', port: 9092 }],
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
        to: [{
          ipBlock: {
            cidr: '192.168.0.1/32',
          },
        }],
        ports: [{ protocol: 'UDP', port: 161 }],
      },
    ],
  },
}
