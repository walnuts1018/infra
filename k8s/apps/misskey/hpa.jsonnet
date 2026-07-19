local app = import 'app.json5';
{
  apiVersion: 'keda.sh/v1alpha1',
  kind: 'ScaledObject',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    minReplicaCount: 2,
    maxReplicaCount: 3,
    scaleTargetRef: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      name: (import 'deployment.jsonnet').metadata.name,
    },
    triggers: [
      {
        type: 'cpu',
        metricType: 'Utilization',
        metadata: {
          value: '80',
        },
      },
    ],
  },
}
