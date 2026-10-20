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
    image: 'docker.io/rabbitmq:4.4.0-management@sha256:c200fd496482cda18c412be4e6f244830e1e75949b8cf5f0e887cea9ea456109',
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
