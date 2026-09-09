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
    minReplicaCount: 0,
    maxReplicaCount: 2,
    cooldownPeriod: 300,
    scaleTargetRef: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      name: (import 'deployment.jsonnet').metadata.name,
    },
    triggers: [
      {
        type: 'external-push',
        metadata: {
          scalerAddress: 'keda-add-ons-http-external-scaler.keda:9090',
          interceptorRoute: app.name,
        },
      },
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
