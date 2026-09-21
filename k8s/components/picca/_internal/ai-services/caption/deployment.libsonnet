function(app)
  local labels = import '../../../../labels.libsonnet';
  local sa = (import '../../sa.libsonnet')(app);
  local rabbitmqSecret = (import '../../rabbitmq/external-secret.libsonnet')(app);
  local storageEnv = (import '../../env/storage.libsonnet')(app);
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: app.name + '-caption-worker',
      namespace: app.namespace,
      labels: labels(app.name + '-caption-worker'),
    },
    spec: {
      strategy: { type: 'Recreate' },
      replicas: 0,
      selector: {
        matchLabels: labels(app.name + '-caption-worker'),
      },
      template: {
        metadata: {
          labels: labels(app.name + '-caption-worker'),
        },
        spec: {
          serviceAccountName: sa.metadata.name,
          imagePullSecrets: [{ name: 'ghcr-login-secret' }],
          containers: [
            std.mergePatch((import '../../../../container.libsonnet') {
              name: 'caption-worker',
              image: 'ghcr.io/walnuts1018/picca/ai-services:v0.0.59',
              imagePullPolicy: 'IfNotPresent',
              command: ['python', 'scripts/run_caption_worker.py'],
              envFrom: [
                { secretRef: { name: rabbitmqSecret.spec.target.name } },
              ],
              env: storageEnv + [
                { name: 'HOME', value: '/tmp' },
                { name: 'HF_HOME', value: '/tmp/huggingface' },
                { name: 'HF_MODULES_CACHE', value: '/tmp/huggingface/modules' },
                { name: 'TRANSFORMERS_CACHE', value: '/tmp/huggingface/transformers' },
                { name: 'PORT', value: '8004' },
                { name: 'MODEL_DEVICE', value: 'cpu' },
                { name: 'FLORENCE2_MODEL_NAME', value: '/models/Florence-2-large-ft' },
                { name: 'AI_CAPTION_TASK_QUEUE', value: 'picca.ai-caption' },
                { name: 'AI_CAPTION_TASK_ROUTING_KEY', value: 'media.processing.ai.caption.requested.v1' },
                { name: 'AI_CAPTION_RESULT_ROUTING_KEY', value: 'media.processing.ai.result.v1' },
                { name: 'AI_RABBITMQ_EXCHANGE', value: 'picca.events' },
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
                reference: 'ghcr.io/walnuts1018/picca/ai-models-caption:v0.0.3',
                pullPolicy: 'IfNotPresent',
              },
            },
          ],
        },
      },
    },
  }
