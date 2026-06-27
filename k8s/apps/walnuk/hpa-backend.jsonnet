local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local deploymentBackend = import 'deployment-backend.jsonnet';
{
  apiVersion: 'autoscaling/v2',
  kind: 'HorizontalPodAutoscaler',
  metadata: {
    name: app.appname.backend,
    namespace: app.namespace,
    labels: (labels)(app.appname.backend),
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
      name: deploymentBackend.metadata.name,
    },
  },
}
