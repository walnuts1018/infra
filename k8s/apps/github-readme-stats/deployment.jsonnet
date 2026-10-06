local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name),
    },
    template: {
      metadata: {
        labels: labels(app.name),
      },
      spec: {
        automountServiceAccountToken: false,
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'github-readme-stats',
            image: 'ghcr.io/walnuts1018/github-readme-stats:v1.0.3@sha256:30f411fb0fd8d9cd23be292810f569519cebec37d3882c0e866e4c6a34b1d7c1',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 80,
              },
            ],
            resources: {
              limits: {
                cpu: '100m',
                memory: '256Mi',
              },
              requests: {
                cpu: '1m',
                memory: '50Mi',
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
            securityContext: (import '../../components/container.libsonnet').securityContext {
              runAsNonRoot: true,
              runAsUser: 1000,
              allowPrivilegeEscalation: false,
            },
          },
        ],
      },
    },
  },
}
