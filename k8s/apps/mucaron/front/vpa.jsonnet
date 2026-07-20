local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  apiVersion: 'autoscaling.k8s.io/v1',
  kind: 'VerticalPodAutoscaler',
  metadata: {
    name: app.name + '-front',
    namespace: app.namespace,
    labels: labels(app.name + '-front'),
  },
  spec: {
    targetRef: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      name: (import 'deployment.jsonnet').metadata.name,
    },
    updatePolicy: {
      updateMode: 'Auto',
    },
    resourcePolicy: {
      containerPolicies: [
        {
          containerName: 'mucaron-front',
          controlledResources: ['cpu', 'memory'],
          minAllowed: {
            memory: '64Mi',
          },
          maxAllowed: {
            memory: '512Mi',
          },
        },
      ],
    },
  },
}
