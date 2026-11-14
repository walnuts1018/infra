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
    image: 'docker.io/rabbitmq:4.4.0-management@sha256:753099a19b577c322117f793f864b3129cbba96d40317221a69d73976e3c843c',
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
