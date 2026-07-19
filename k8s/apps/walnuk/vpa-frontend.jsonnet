local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'autoscaling.k8s.io/v1',
  kind: 'VerticalPodAutoscaler',
  metadata: {
    name: app.appname.frontend,
    namespace: app.namespace,
    labels: labels(app.appname.frontend),
  },
  spec: {
    targetRef: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      name: (import 'deployment-frontend.jsonnet').metadata.name,
    },
    updatePolicy: {
      updateMode: 'Auto',
    },
    resourcePolicy: {
      containerPolicies: [
        {
          containerName: 'next',
          controlledResources: ['memory'],
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
