local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-caption-service',
    namespace: app.namespace,
    labels: labels(app.name + '-caption-service'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name + '-caption-service'),
    },
    template: {
      metadata: {
        labels: labels(app.name + '-caption-service'),
      },
      spec: {
        serviceAccountName: (import '../sa.jsonnet').metadata.name,
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        containers: [
          std.mergePatch((import '../../../components/container.libsonnet') {
            name: 'caption-service',
            image: 'ghcr.io/walnuts1018/picca/ai-services:v0.0.48',
            imagePullPolicy: 'IfNotPresent',
            command: ['python', 'scripts/run_caption_service.py'],
            env: [
              { name: 'PORT', value: '8004' },
              { name: 'MODEL_DEVICE', value: 'cpu' },
              { name: 'FLORENCE2_MODEL_NAME', value: '/models/Florence-2-base-ft' },
              { name: 'TRANSLATE_MODEL_NAME', value: '/models/CAT-Translate-0.8b' },
            ],
            ports: [
              { name: 'http', containerPort: 8004 },
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
