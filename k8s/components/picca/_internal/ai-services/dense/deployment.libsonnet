function(app)
  local labels = import '../../../../labels.libsonnet';
  local sa = (import '../../sa.libsonnet')(app);
  local rabbitmqSecret = (import '../../rabbitmq/external-secret.libsonnet')(app);
  local storageEnv = (import '../../env/storage.libsonnet')(app);
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: app.name + '-dense-service',
      namespace: app.namespace,
      labels: labels(app.name + '-dense-service'),
    },
    spec: {
      // モデルイメージを同一ノード上で重複してロードしないよう、更新時は旧Podを先に停止する。
      strategy: { type: 'Recreate' },
      replicas: 1,
      selector: {
        matchLabels: labels(app.name + '-dense-service'),
      },
      template: {
        metadata: {
          labels: labels(app.name + '-dense-service'),
        },
        spec: {
          serviceAccountName: sa.metadata.name,
          imagePullSecrets: [{ name: 'ghcr-login-secret' }],
          containers: [
            std.mergePatch((import '../../../../container.libsonnet') {
              name: 'dense-service',
              image: 'ghcr.io/walnuts1018/picca/ai-services:v0.0.61',
              imagePullPolicy: 'IfNotPresent',
              command: ['python', 'scripts/run_dense_service.py'],
              envFrom: [
                { secretRef: { name: rabbitmqSecret.spec.target.name } },
              ],
              env: storageEnv + [
                { name: 'HOME', value: '/tmp' },
                { name: 'HF_HOME', value: '/tmp/huggingface' },
                { name: 'HF_MODULES_CACHE', value: '/tmp/huggingface/modules' },
                { name: 'TRANSFORMERS_CACHE', value: '/tmp/huggingface/transformers' },
                { name: 'PORT', value: '8001' },
                { name: 'MODEL_DEVICE', value: 'cpu' },
                { name: 'DENSE_INFERENCE_BACKEND', value: 'openvino' },
                { name: 'AI_INFERENCE_THREADS', value: '2' },
                { name: 'OMP_NUM_THREADS', value: '2' },
                { name: 'MKL_NUM_THREADS', value: '2' },
                { name: 'OPENBLAS_NUM_THREADS', value: '2' },
                { name: 'NUMEXPR_NUM_THREADS', value: '2' },
                { name: 'TOKENIZERS_PARALLELISM', value: 'false' },
                { name: 'OPENVINO_TENSOR_CACHE_PATH', value: '/tmp/runtime-cache/openvino' },
                { name: 'OPENVINO_CACHE_DIR', value: '/tmp/runtime-cache/openvino' },
                { name: 'OV_CACHE_DIR', value: '/tmp/runtime-cache/openvino' },
                { name: 'DENSE_OPENVINO_TEXT_MODEL', value: '/models/waon-siglip2-base-patch16-256/openvino/text_model.xml' },
                { name: 'DENSE_OPENVINO_IMAGE_MODEL', value: '/models/waon-siglip2-base-patch16-256/openvino/image_model.xml' },
                { name: 'DENSE_MODEL_NAME', value: '/models/waon-siglip2-base-patch16-256' },
                { name: 'CAT_TRANSLATE_MODEL_NAME', value: '/models/CAT-Translate-0.8b' },
                { name: 'CAT_SOURCE_LANGUAGE', value: 'Japanese' },
                { name: 'CAT_TARGET_LANGUAGE', value: 'English' },
                { name: 'CAT_TRANSLATE_IDLE_SECONDS', value: '300' },
                { name: 'AI_DENSE_TASK_QUEUE', value: 'picca.ai-dense' },
                { name: 'AI_DENSE_TASK_ROUTING_KEY', value: 'media.processing.ai.dense.requested.v1' },
                { name: 'AI_DENSE_RESULT_ROUTING_KEY', value: 'media.processing.ai.result.v1' },
                { name: 'AI_RABBITMQ_EXCHANGE', value: 'picca.events' },
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
              startupProbe: {
                httpGet: { path: '/healthz', port: 'http' },
                periodSeconds: 10,
                failureThreshold: 180,
              },
              resources: {
                requests: { cpu: '2', memory: '8Gi' },
                limits: { cpu: '4', memory: '16Gi' },
              },
              volumeMounts: [
                { name: 'tmp', mountPath: '/tmp' },
                { name: 'runtime-cache', mountPath: '/tmp/runtime-cache' },
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
            { name: 'runtime-cache', emptyDir: { sizeLimit: '2Gi' } },
            {
              name: 'models',
              image: {
                reference: 'ghcr.io/walnuts1018/picca/ai-models-dense:v0.0.61',
                pullPolicy: 'IfNotPresent',
              },
            },
          ],
        },
      },
    },
  }
