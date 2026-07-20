local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  apiVersion: 'autoscaling.k8s.io/v1',
  kind: 'VerticalPodAutoscaler',
  metadata: {
    name: app.name + '-back',
    namespace: app.namespace,
    labels: labels(app.name + '-back'),
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
          containerName: 'openchokin-back',
          controlledResources: ['cpu', 'memory'],
          minAllowed: {
            cpu: '1m',
            memory: '10Mi',
          },
          maxAllowed: {
            cpu: '500m',
            memory: '128Mi',
          },
        },
      ],
    },
  },
}
