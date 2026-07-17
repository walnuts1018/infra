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
    },
    labels: labels('akvorado-kafka'),
  },
  spec: {
    kafka: {
      version: '3.9.0',
      replicas: 1,
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
        'inter.broker.protocol.version': '3.9',
      },
      storage: {
        type: 'persistent-claim',
        size: '10Gi',
        deleteClaim: false,
      },
      resources: {
        requests: {
          cpu: '100m',
          memory: '512Mi',
        },
        limits: {
          cpu: '2',
          memory: '2Gi',
        },
      },
    },
    zookeeper: {
      replicas: 1,
      storage: {
        type: 'persistent-claim',
        size: '5Gi',
        deleteClaim: false,
      },
      resources: {
        requests: {
          cpu: '50m',
          memory: '256Mi',
        },
        limits: {
          cpu: '500m',
          memory: '512Mi',
        },
      },
    },
    entityOperator: {
      topicOperator: {},
      userOperator: {},
    },
  },
}
