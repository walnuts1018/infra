local app = import 'app.json5';
{
  apiVersion: 'autoscaling/v2',
  kind: 'HorizontalPodAutoscaler',
  metadata: {
    name: app.appname.frontend,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.appname.frontend),
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
      name: (import 'deployment-frontend.jsonnet').metadata.name,
    },
  },
}
