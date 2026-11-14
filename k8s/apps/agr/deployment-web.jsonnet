local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-web',
    namespace: app.namespace,
    labels: labels(app.name + '-web'),
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: labels(app.name + '-web'),
    },
    template: {
      metadata: {
        labels: labels(app.name + '-web'),
      },
      spec: {
        automountServiceAccountToken: false,
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        securityContext: {
          runAsUser: 65532,
          runAsGroup: 65532,
          fsGroup: 65532,
        },
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'web',
            image: 'ghcr.io/walnuts1018/agr-web:0.1.0',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              { name: 'http', containerPort: 3000, protocol: 'TCP' },
            ],
            env: [
              { name: 'NODE_ENV', value: 'production' },
              { name: 'NEXT_TELEMETRY_DISABLED', value: '1' },
            ],
            resources: {
              requests: { cpu: '50m', memory: '256Mi' },
              limits: { cpu: '1', memory: '1Gi' },
            },
            livenessProbe: {
              httpGet: { path: '/', port: 'http' },
              periodSeconds: 20,
              timeoutSeconds: 3,
            },
            readinessProbe: {
              httpGet: { path: '/', port: 'http' },
              periodSeconds: 10,
              timeoutSeconds: 3,
            },
            volumeMounts: [
              { name: 'next-cache', mountPath: '/app/web/.next/cache' },
            ],
          }, {
            securityContext: {
              runAsNonRoot: true,
              allowPrivilegeEscalation: false,
            },
          }),
        ],
        volumes: [
          { name: 'next-cache', emptyDir: {} },
        ],
      },
    },
  },
}
