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
    maxReplicas: 5,
    metrics: [
      {
        resource: {
          name: 'cpu',
          target: {
            averageUtilization: 100,
            type: 'Utilization',
          },
        },
        type: 'Resource',
      },
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
      name: (import 'deployment.jsonnet').metadata.name,
    },
  },
}
