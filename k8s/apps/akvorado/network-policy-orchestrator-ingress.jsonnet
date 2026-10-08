local labels = import '../../components/labels.libsonnet';
local networkPolicy = import '../../components/network-policy.libsonnet';
local app = import 'app.json5';

local sameNamespace(podLabels) = {
  namespaceSelector: {
    matchLabels: {
      'kubernetes.io/metadata.name': app.namespace,
    },
  },
  podSelector: {
    matchLabels: podLabels,
  },
};

{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'NetworkPolicy',
  metadata: {
    name: app.name + '-orchestrator-ingress',
    namespace: app.namespace,
  },
  spec: {
    podSelector: {
      matchLabels: labels(app.name) + {
        'app.kubernetes.io/component': 'orchestrator',
      },
    },
    policyTypes: ['Ingress'],
    ingress: [{
      from: [
        sameNamespace(labels(app.name) + {
          'app.kubernetes.io/component': 'console',
        }),
        sameNamespace(labels(app.name) + {
          'app.kubernetes.io/component': 'outlet',
        }),
        sameNamespace({
          'app.kubernetes.io/name': 'clickhouse-server',
          'clickhouse.com/cluster': 'akvorado-clickhouse',
          'clickhouse.com/role': 'clickhouse-server',
        }),
        networkPolicy.otelPrometheusCollector,
      ],
      ports: [{ protocol: 'TCP', port: 8080 }],
    }],
  },
}
