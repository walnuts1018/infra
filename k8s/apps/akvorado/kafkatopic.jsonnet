local app = import 'app.json5';
local labels = import '../../components/labels.libsonnet';
{
  apiVersion: 'kafka.strimzi.io/v1beta2',
  kind: 'KafkaTopic',
  metadata: {
    name: 'flows',
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
    labels: labels('akvorado-kafka-topic') + {
      'strimzi.io/cluster': 'akvorado-kafka',
    },
  },
  spec: {
    partitions: 2,
    replicas: 1,
    config: {
      'retention.ms': 604800000,  // 7 days
      'segment.bytes': 1073741824,
    },
  },
}
