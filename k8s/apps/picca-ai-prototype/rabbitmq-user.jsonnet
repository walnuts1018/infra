{
  apiVersion: 'rabbitmq.com/v1beta1',
  kind: 'User',
  metadata: {
    name: 'picca-ai-prototype-app',
    namespace: (import 'app.json5').namespace,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name + '-rabbitmq-user'),
  },
  spec: {
    rabbitmqClusterReference: {
      name: (import '../rabbitmq-default/rabbitmqcluster.jsonnet').metadata.name,
      namespace: (import '../rabbitmq-default/rabbitmqcluster.jsonnet').metadata.namespace,
    },
    importCredentialsSecret: {
      name: (import 'external-secret-rabbitmq-app-user.jsonnet').spec.target.name,
    },
  },
}
