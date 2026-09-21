function(app)
  local labels = import '../../../../labels.libsonnet';
  local sa = (import '../../sa.libsonnet')(app);
  local rabbitmqSecret = (import '../../rabbitmq/external-secret.libsonnet')(app);
  local storageEnv = (import '../../env/storage.libsonnet')(app);
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: app.name + '-sparse-service',
      namespace: app.namespace,
      labels: labels(app.name + '-sparse-service'),
    },
    spec: {
      // モデルイメージを同一ノード上で重複してロードしないよう、更新時は旧Podを先に停止する。
      strategy: { type: 'Recreate' },
      replicas: 1,
      selector: {
        matchLabels: labels(app.name + '-sparse-service'),
      },
      template: {
        metadata: {
          labels: labels(app.name + '-sparse-service'),
        },
        spec: {
          serviceAccountName: sa.metadata.name,
          imagePullSecrets: [{ name: 'ghcr-login-secret' }],
          containers: [
            std.mergePatch((import '../../../../container.libsonnet') {
              name: 'sparse-service',
              image: 'ghcr.io/walnuts1018/picca/ai-services:v0.0.57',
              imagePullPolicy: 'IfNotPresent',
              command: ['python', 'scripts/run_sparse_service.py'],
              envFrom: [
                { secretRef: { name: rabbitmqSecret.spec.target.name } },
              ],
              env: storageEnv + [
                { name: 'PORT', value: '8002' },
                { name: 'MODEL_DEVICE', value: 'cpu' },
                { name: 'SPARSE_MODEL_NAME', value: '/models/light-splade-japanese-28M' },
                { name: 'AI_SPARSE_TASK_QUEUE', value: 'picca.ai-sparse' },
                { name: 'AI_SPARSE_TASK_ROUTING_KEY', value: 'media.processing.ai.sparse.requested.v1' },
                { name: 'AI_SPARSE_RESULT_ROUTING_KEY', value: 'media.processing.ai.result.v1' },
                { name: 'AI_RABBITMQ_EXCHANGE', value: 'picca.events' },
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
                reference: 'ghcr.io/walnuts1018/picca/ai-models-sparse:v0.0.1',
                pullPolicy: 'IfNotPresent',
              },
            },
          ],
        },
      },
    },
  }
