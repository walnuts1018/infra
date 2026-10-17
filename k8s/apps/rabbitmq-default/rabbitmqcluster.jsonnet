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
    image: 'docker.io/rabbitmq:4.3.6-management@sha256:ca5d088daf64c9de02c923c1c57c724bf4884c5c69bfa8172c68b214c0057cea',
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
