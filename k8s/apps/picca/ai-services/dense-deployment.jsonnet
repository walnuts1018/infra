local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-dense-service',
    namespace: app.namespace,
    labels: labels(app.name + '-dense-service'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name + '-dense-service'),
    },
    template: {
      metadata: {
        labels: labels(app.name + '-dense-service'),
      },
      spec: {
        serviceAccountName: (import '../sa.jsonnet').metadata.name,
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        containers: [
          std.mergePatch((import '../../../components/container.libsonnet') {
            name: 'dense-service',
            image: 'ghcr.io/walnuts1018/picca/ai-services:v0.0.48',
            imagePullPolicy: 'IfNotPresent',
            command: ['python', 'scripts/run_dense_service.py'],
            env: [
              { name: 'PORT', value: '8001' },
              { name: 'MODEL_DEVICE', value: 'cpu' },
              { name: 'DENSE_MODEL_NAME', value: '/models/waon-siglip2-base-patch16-256' },
            ],
            ports: [
              { name: 'http', containerPort: 8001 },
            ],
            readinessProbe: {
              httpGet: { path: '/healthz', port: 'http' },
              periodSeconds: 10,
              failureThreshold: 3,
            },
            livenessProbe: {
              httpGet: { path: '/healthz', port: 'http' },
              periodSeconds: 10,
              failureThreshold: 3,
            },
            resources: {
              requests: { cpu: '1', memory: '2Gi' },
              limits: { cpu: '4', memory: '6Gi' },
            },
            volumeMounts: [
              { name: 'tmp', mountPath: '/tmp' },
              { name: 'models', mountPath: '/models', readOnly: true },
            ],
          }, {
            securityContext: {
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: false,
            },
          }),
        ],
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 65532,
          runAsGroup: 65532,
        },
        volumes: [
          { name: 'tmp', emptyDir: {} },
          {
            name: 'models',
            image: {
              reference: 'ghcr.io/walnuts1018/picca/ai-models:v0.0.47',
              pullPolicy: 'IfNotPresent',
            },
          },
        ],
      },
    },
  },
}
