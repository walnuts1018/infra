local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'autoscaling.k8s.io/v1',
  kind: 'VerticalPodAutoscaler',
  metadata: {
    name: app.appname.backend,
    namespace: app.namespace,
    labels: labels(app.appname.backend),
  },
  spec: {
    targetRef: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      name: (import 'deployment-backend.jsonnet').metadata.name,
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
            cpu: '5m',
            memory: '10Mi',
          },
          maxAllowed: {
            cpu: '500m',
            memory: '256Mi',
          },
        },
      ],
    },
  },
}
