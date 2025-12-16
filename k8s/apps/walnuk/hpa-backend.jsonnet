{
  apiVersion: 'autoscaling/v2',
  kind: 'HorizontalPodAutoscaler',
  metadata: {
    name: (import 'app.json5').appname.backend,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').appname.backend),
  },
  spec: {
    minReplicas: 2,
    maxReplicas: 5,
    metrics: [
      {
        resource: {
          name: 'memory',
          target: {
            averageUtilization: 100,
            type: 'Utilization',
          },
        },
        type: 'Resource',
      },
    ],
    scaleTargetRef: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      name: (import 'deployment-backend.jsonnet').metadata.name,
    },
  },
}
