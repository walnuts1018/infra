{
  apiVersion: 'autoscaling/v2',
  kind: 'HorizontalPodAutoscaler',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    minReplicas: 2,
    maxReplicas: 4,
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
      name: 'zitadel',
    },
  },
}
