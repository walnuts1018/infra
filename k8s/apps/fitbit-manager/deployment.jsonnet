local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (labels)(app.name),
    },
    template: {
      metadata: {
        labels: (labels)(app.name),
      },
      spec: {
        securityContext: {
          runAsUser: 65532,
          runAsGroup: 65532,
        },
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'fitbit-manager',
            image: 'ghcr.io/walnuts1018/fitbit-manager:1.0.5',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 8080,
              },
            ],
            resources: {
              requests: {
                cpu: '1m',
                memory: '10Mi',
              },
              limits: {
                cpu: '100m',
                memory: '300Mi',
              },
            },
            env: (import 'env.libsonnet').env,
          },
        ],
      },
    },
  },
}
