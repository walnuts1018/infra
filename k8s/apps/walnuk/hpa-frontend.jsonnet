local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local deploymentFrontend = import 'deployment-frontend.jsonnet';
{
  apiVersion: 'autoscaling/v2',
  kind: 'HorizontalPodAutoscaler',
  metadata: {
    name: app.appname.frontend,
    namespace: app.namespace,
    labels: (labels)(app.appname.frontend),
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
      name: deploymentFrontend.metadata.name,
    },
  },
}
