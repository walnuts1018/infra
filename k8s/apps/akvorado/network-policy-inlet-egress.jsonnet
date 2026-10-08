local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: 'akvorado-inlet-egress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: {
        'app.kubernetes.io/component': 'inlet',
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
        to: [{
          namespaceSelector: {
            matchLabels: {
              'kubernetes.io/metadata.name': app.namespace,
            },
          },
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
    ],
  },
}
