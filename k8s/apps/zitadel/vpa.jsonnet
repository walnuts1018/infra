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
      name: 'zitadel',
    },
    updatePolicy: {
      updateMode: 'Auto',
    },
    resourcePolicy: {
      containerPolicies: [
        {
          containerName: 'zitadel',
          controlledResources: ['memory'],
          minAllowed: {
            cpu: '100m',
            memory: '128Mi',
          },
          maxAllowed: {
            cpu: '500m',
            memory: '1Gi',
          },
        },
      ],
    },
  },
}
