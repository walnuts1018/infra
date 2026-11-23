local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local deployment = import 'deployment-server.jsonnet';
{
  apiVersion: 'autoscaling/v2',
  kind: 'HorizontalPodAutoscaler',
  metadata: {
    name: deployment.metadata.name,
    namespace: app.namespace,
    labels: labels(deployment.metadata.name),
  },
  spec: {
    scaleTargetRef: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      name: deployment.metadata.name,
    },
    minReplicas: 2,
    maxReplicas: 8,
    metrics: [
      {
        type: 'Resource',
        resource: {
          name: 'cpu',
          target: {
            type: 'Utilization',
            averageUtilization: 70,
          },
        },
      },
    ],
    behavior: {
      scaleUp: {
        stabilizationWindowSeconds: 60,
      },
      scaleDown: {
        stabilizationWindowSeconds: 300,
      },
    },
  },
}
