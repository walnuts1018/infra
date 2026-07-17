local app = import 'app.json5';
local labels = import '../../components/labels.libsonnet';
{
  apiVersion: 'kafka.strimzi.io/v1',
  kind: 'KafkaNodePool',
  metadata: {
    name: 'akvorado-kafka-pool',
    namespace: app.namespace,
    labels: labels('akvorado-kafka-pool') + {
      'strimzi.io/cluster': 'akvorado-kafka',
    },
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
  },
  spec: {
    replicas: 1,
    roles: ['broker', 'controller'],
    storage: {
      type: 'persistent-claim',
      size: '10Gi',
      deleteClaim: false,
    },
    resources: {
      requests: {
        cpu: '29m',
        memory: '459Mi',
      },
      limits: {
        cpu: '2',
        memory: '2Gi',
      },
    },
  },
}
