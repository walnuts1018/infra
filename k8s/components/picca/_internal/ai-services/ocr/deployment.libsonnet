function(app)
  local labels = import '../../../../labels.libsonnet';
  local sa = (import '../../sa.libsonnet')(app);
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: app.name + '-ocr-service',
      namespace: app.namespace,
      labels: labels(app.name + '-ocr-service'),
    },
    spec: {
      replicas: 1,
      selector: {
        matchLabels: labels(app.name + '-ocr-service'),
      },
      template: {
        metadata: {
          labels: labels(app.name + '-ocr-service'),
        },
        spec: {
          serviceAccountName: sa.metadata.name,
          imagePullSecrets: [{ name: 'ghcr-login-secret' }],
          containers: [
            std.mergePatch((import '../../../../container.libsonnet') {
              name: 'ocr-service',
              image: 'ghcr.io/walnuts1018/picca/ai-services:v0.0.49',
              imagePullPolicy: 'IfNotPresent',
              command: ['python', 'scripts/run_ocr_service.py'],
              env: [
                { name: 'PORT', value: '8003' },
                { name: 'MODEL_DEVICE', value: 'cpu' },
              ],
              ports: [
                { name: 'http', containerPort: 8003 },
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
                reference: 'ghcr.io/walnuts1018/picca/ai-models-ocr:v0.0.1',
                pullPolicy: 'IfNotPresent',
              },
            },
          ],
        },
      },
    },
  }
