{
  apiVersion: 'rabbitmq.com/v1beta1',
  kind: 'RabbitmqCluster',
  metadata: {
    name: 'default',
    namespace: (import 'app.json5').namespace,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
      'rabbitmq.com/topology-allowed-namespaces': 'picca-ai-prototype',
    },
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    replicas: 1,
    image: 'rabbitmq:4.3.0-management',
    persistence: {
      storage: '10Gi',
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
}
