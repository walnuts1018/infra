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
    image: 'docker.io/rabbitmq:4.3.6-management@sha256:54cb013d76cd1fd6c0a0708f34062ad61c452bb6f016b434c6c33f1a765d2b58',
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
