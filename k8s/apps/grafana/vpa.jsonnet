local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'autoscaling.k8s.io/v1',
  kind: 'VerticalPodAutoscaler',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    targetRef: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      name: app.name,
    },
    updatePolicy: {
      updateMode: 'Auto',
    },
    resourcePolicy: {
      containerPolicies: [
        {
          containerName: 'grafana',
          controlledResources: ['memory'],
          minAllowed: {
            memory: '256Mi',
          },
          maxAllowed: {
            memory: '1Gi',
          },
        },
      ],
    },
  },
}
