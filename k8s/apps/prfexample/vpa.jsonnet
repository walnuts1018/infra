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
      name: (import 'deployment.jsonnet').metadata.name,
    },
    updatePolicy: {
      updateMode: 'Auto',
    },
    resourcePolicy: {
      containerPolicies: [
        {
          containerName: 'apiserver',
          controlledResources: ['memory'],
          minAllowed: {
            memory: '10Mi',
          },
          maxAllowed: {
            memory: '256Mi',
          },
        },
      ],
    },
  },
}
