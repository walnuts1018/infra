function(app)
  local labels = import '../../../../labels.libsonnet';
  local sa = (import '../../sa.libsonnet')(app);
  local rabbitmqSecret = (import '../../rabbitmq/external-secret.libsonnet')(app);
  local storageEnv = (import '../../env/storage.libsonnet')(app);
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: app.name + '-ocr-worker',
      namespace: app.namespace,
      labels: labels(app.name + '-ocr-worker'),
    },
    spec: {
      strategy: { type: 'Recreate' },
      replicas: 0,
      selector: {
        matchLabels: labels(app.name + '-ocr-worker'),
      },
      template: {
        metadata: {
          labels: labels(app.name + '-ocr-worker'),
        },
        spec: {
          serviceAccountName: sa.metadata.name,
          imagePullSecrets: [{ name: 'ghcr-login-secret' }],
          containers: [
            std.mergePatch((import '../../../../container.libsonnet') {
              name: 'ocr-worker',
              image: 'ghcr.io/walnuts1018/picca/ai-services:v0.0.59',
              imagePullPolicy: 'IfNotPresent',
              command: ['python', 'scripts/run_ocr_worker.py'],
              envFrom: [
                { secretRef: { name: rabbitmqSecret.spec.target.name } },
              ],
              env: storageEnv + [
                { name: 'HOME', value: '/tmp' },
                { name: 'HF_HOME', value: '/tmp/huggingface' },
                { name: 'HF_MODULES_CACHE', value: '/tmp/huggingface/modules' },
                { name: 'TRANSFORMERS_CACHE', value: '/tmp/huggingface/transformers' },
                { name: 'PADDLEX_HOME', value: '/models/paddlex' },
                { name: 'PADDLE_HOME', value: '/models/paddlex' },
                { name: 'PADDLE_PDX_HOME', value: '/models/paddlex' },
                { name: 'PORT', value: '8003' },
                { name: 'MODEL_DEVICE', value: 'cpu' },
                { name: 'OCR_TEXT_DETECTION_MODEL_NAME', value: 'PP-OCRv6_medium_det' },
                { name: 'OCR_TEXT_RECOGNITION_MODEL_NAME', value: 'PP-OCRv6_medium_rec' },
                { name: 'OCR_VL_MODEL_NAME', value: 'PaddleOCR-VL-1.6' },
                { name: 'OCR_VL_FALLBACK_REGION_COUNT', value: '12' },
                { name: 'OCR_VL_FALLBACK_CHARACTER_COUNT', value: '200' },
                { name: 'OCR_VL_FALLBACK_TEXT_AREA_RATIO', value: '0.20' },
                { name: 'OCR_VL_FALLBACK_LOW_CONFIDENCE', value: '0.75' },
                { name: 'AI_OCR_TASK_QUEUE', value: 'picca.ai-ocr' },
                { name: 'AI_OCR_TASK_ROUTING_KEY', value: 'media.processing.ai.ocr.requested.v1' },
                { name: 'AI_OCR_RESULT_ROUTING_KEY', value: 'media.processing.ai.result.v1' },
                { name: 'AI_RABBITMQ_EXCHANGE', value: 'picca.events' },
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
              startupProbe: {
                httpGet: { path: '/healthz', port: 'http' },
                periodSeconds: 10,
                failureThreshold: 60,
              },
              resources: {
                requests: { cpu: '1', memory: '6Gi' },
                limits: { cpu: '4', memory: '12Gi' },
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
                reference: 'ghcr.io/walnuts1018/picca/ai-models-ocr:v0.0.59',
                pullPolicy: 'IfNotPresent',
              },
            },
          ],
        },
      },
    },
  }
