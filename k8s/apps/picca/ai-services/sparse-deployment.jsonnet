local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-sparse-service',
    namespace: app.namespace,
    labels: labels(app.name + '-sparse-service'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name + '-sparse-service'),
    },
    template: {
      metadata: {
        labels: labels(app.name + '-sparse-service'),
      },
      spec: {
        serviceAccountName: (import '../sa.jsonnet').metadata.name,
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        containers: [
          std.mergePatch((import '../../../components/container.libsonnet') {
            name: 'sparse-service',
            image: 'ghcr.io/walnuts1018/picca/ai-services:v0.0.49',
            imagePullPolicy: 'IfNotPresent',
            command: ['python', 'scripts/run_sparse_service.py'],
            env: [
              { name: 'PORT', value: '8002' },
              { name: 'MODEL_DEVICE', value: 'cpu' },
              { name: 'SPARSE_MODEL_NAME', value: '/models/light-splade-japanese-28M' },
            ],
            ports: [
              { name: 'http', containerPort: 8002 },
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
              requests: { cpu: '250m', memory: '512Mi' },
              limits: { cpu: '1', memory: '1Gi' },
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
