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
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'github-readme-stats',
            image: 'ghcr.io/walnuts1018/github-readme-stats:v1.0.3',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 80,
              },
            ],
            resources: {
              limits: {},
              requests: {
                memory: '32Mi',
              },
            },
            env: [
              {
                name: 'PAT_1',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'github-token',
                  },
                },
              },
            ],
          },
        ],
      },
    },
  },
}
