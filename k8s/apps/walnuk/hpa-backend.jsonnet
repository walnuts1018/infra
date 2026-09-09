local app = import 'app.json5';
{
  apiVersion: 'keda.sh/v1alpha1',
  kind: 'ScaledObject',
  metadata: {
    name: app.appname.backend,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.appname.backend),
  },
  spec: {
    minReplicaCount: 2,
    maxReplicaCount: 5,
    scaleTargetRef: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      name: (import 'deployment-backend.jsonnet').metadata.name,
    },
    triggers: [
      {
        type: 'cpu',
        metricType: 'Utilization',
        metadata: {
          value: '95',
        },
      },
    ],
  },
}
