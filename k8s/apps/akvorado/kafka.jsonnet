local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'kafka.strimzi.io/v1',
  kind: 'Kafka',
  metadata: {
    name: 'akvorado-kafka',
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
      'strimzi.io/node-pools': 'enabled',
    },
    labels: labels('akvorado-kafka'),
  },
  spec: {
    kafka: {
      version: '4.3.0',
      listeners: [
        {
          name: 'plain',
          port: 9092,
          type: 'internal',
          tls: false,
        },
      ],
      config: {
        'offsets.topic.replication.factor': 1,
        'transaction.state.log.replication.factor': 1,
        'transaction.state.log.min.isr': 1,
        'default.replication.factor': 1,
        'min.insync.replicas': 1,
      },
    },
    entityOperator: {
      topicOperator: {},
      userOperator: {},
    },
  },
}
