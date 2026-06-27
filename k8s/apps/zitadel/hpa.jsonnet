local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'autoscaling/v2',
  kind: 'HorizontalPodAutoscaler',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    minReplicas: 1,
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
