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
          initContainers: [
            {
              name: 'prepare-paddlex-models',
              image: 'ghcr.io/walnuts1018/picca/ai-services:v0.0.61',
              command: ['sh', '-c', 'cp -a /model-source/paddlex/. /models/paddlex/ && chmod -R a+rwX /models/paddlex'],
              securityContext: {
                allowPrivilegeEscalation: false,
                runAsUser: 0,
                runAsGroup: 0,
                runAsNonRoot: false,
                readOnlyRootFilesystem: false,
              },
              volumeMounts: [
                { name: 'model-source', mountPath: '/model-source', readOnly: true },
                { name: 'paddlex-models', mountPath: '/models/paddlex' },
              ],
            },
          ],
          containers: [
            std.mergePatch((import '../../../../container.libsonnet') {
              name: 'ocr-worker',
              image: 'ghcr.io/walnuts1018/picca/ai-services:v0.0.61',
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
                { name: 'PADDLE_CPU_THREADS', value: '2' },
                { name: 'PADDLE_ENABLE_HPI', value: 'true' },
                { name: 'PADDLE_ENABLE_MKLDNN', value: 'false' },
                { name: 'PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK', value: '1' },
                { name: 'PORT', value: '8003' },
                { name: 'MODEL_DEVICE', value: 'cpu' },
                { name: 'AI_INFERENCE_THREADS', value: '2' },
                { name: 'OMP_NUM_THREADS', value: '2' },
                { name: 'MKL_NUM_THREADS', value: '2' },
                { name: 'OPENBLAS_NUM_THREADS', value: '2' },
                { name: 'NUMEXPR_NUM_THREADS', value: '2' },
                { name: 'TOKENIZERS_PARALLELISM', value: 'false' },
                { name: 'OCR_TEXT_DETECTION_MODEL_NAME', value: 'PP-OCRv6_medium_det' },
                { name: 'OCR_TEXT_RECOGNITION_MODEL_NAME', value: 'PP-OCRv6_medium_rec' },
                { name: 'PADDLE_CACHE_DIR', value: '/tmp/runtime-cache/paddle' },
                { name: 'PADDLEOCR_HOME', value: '/tmp/runtime-cache/paddleocr' },
                { name: 'OPENVINO_TENSOR_CACHE_PATH', value: '/tmp/runtime-cache/openvino' },
                { name: 'OPENVINO_CACHE_DIR', value: '/tmp/runtime-cache/openvino' },
                { name: 'OV_CACHE_DIR', value: '/tmp/runtime-cache/openvino' },
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
                { name: 'runtime-cache', mountPath: '/tmp/runtime-cache' },
                { name: 'paddlex-models', mountPath: '/models/paddlex' },
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
            { name: 'runtime-cache', emptyDir: { sizeLimit: '4Gi' } },
            { name: 'paddlex-models', emptyDir: { sizeLimit: '8Gi' } },
            {
              name: 'model-source',
              image: {
                reference: 'ghcr.io/walnuts1018/picca/ai-models-ocr:v0.0.60',
                pullPolicy: 'IfNotPresent',
              },
            },
          ],
        },
      },
    },
  }
