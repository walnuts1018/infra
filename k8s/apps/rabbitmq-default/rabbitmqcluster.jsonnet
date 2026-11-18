local storage = import '../../components/storage.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'rabbitmq.com/v1beta1',
  kind: 'RabbitmqCluster',
  metadata: {
    name: 'default',
    namespace: app.namespace,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
      'rabbitmq.com/topology-allowed-namespaces': 'picca,picca-dev,beast,horse',
    },
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    affinity: storage.avoidSlowNodeAffinity,
    replicas: 1,
    image: 'docker.io/rabbitmq:4.4.1-management@sha256:61f90c401a5b5ed2486771973ea92ad66046471eacab9c9149f1a6e091c91677',
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
