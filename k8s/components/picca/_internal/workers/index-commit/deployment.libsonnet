function(app)
  local labels = import '../../../../labels.libsonnet';
  local commonEnv = (import '../../env/common.libsonnet')(app, '12');
  local postgresSecret = (import '../../postgres/external-secret.libsonnet')(app);
  local valkeySecret = (import '../../valkey/external-secret.libsonnet')(app);
  local rabbitmqSecret = (import '../../rabbitmq/external-secret.libsonnet')(app);
  local oidcSecret = (import '../../oidc/external-secret.libsonnet')(app);
  local graphqlSigningSecret = (import '../../common/graphql-signing-secret.libsonnet')(app);
  local albumCapabilitySecret = (import '../../common/album-capability-secret.libsonnet')(app);
  local s3Irsa = (import '../../s3-irsa.libsonnet')(app);
  local sa = (import '../../sa.libsonnet')(app);
  local workerName = app.name + '-index-commit-worker';
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: workerName,
      namespace: app.namespace,
      labels: labels(workerName),
    },
    spec: {
      replicas: 0,
      selector: { matchLabels: labels(workerName) },
      template: {
        metadata: { labels: labels(workerName) },
        spec: {
          serviceAccountName: sa.metadata.name,
          imagePullSecrets: [{ name: 'ghcr-login-secret' }],
          containers: [
            (import '../../../../container.libsonnet') {
              name: 'index-commit-worker',
              image: 'ghcr.io/walnuts1018/picca/index-commit-worker:v0.0.94@sha256:a557cf5f27d3687e35199fb8ffa145c009d80c1d7f98c64a8027870deec165f1',
              imagePullPolicy: 'IfNotPresent',
              envFrom: [
                { secretRef: { name: postgresSecret.spec.target.name } },
                { secretRef: { name: valkeySecret.spec.target.name } },
                { secretRef: { name: rabbitmqSecret.spec.target.name } },
                { secretRef: { name: oidcSecret.spec.target.name } },
                { secretRef: { name: graphqlSigningSecret.spec.target.name } },
                { secretRef: { name: albumCapabilitySecret.spec.target.name } },
              ],
              env: commonEnv + s3Irsa.env + [
                { name: 'OTEL_SERVICE_NAME', value: workerName },
                { name: 'AI_INDEX_COMMIT_QUEUE', value: 'picca.ai-result' },
                { name: 'AI_RESULT_ROUTING_KEY', value: 'media.processing.ai.result.v1' },
                { name: 'AI_RABBITMQ_EXCHANGE', value: 'picca.events' },
              ],
              resources: {
                requests: { cpu: '250m', memory: '256Mi' },
                limits: { cpu: '2', memory: '1Gi' },
              },
              ports: [{ containerPort: 8080, name: 'health' }],
              startupProbe: {
                httpGet: { path: '/healthz', port: 'health' },
                periodSeconds: 10,
                failureThreshold: 18,
              },
              livenessProbe: {
                httpGet: { path: '/healthz', port: 'health' },
                periodSeconds: 15,
                failureThreshold: 3,
              },
              volumeMounts: [
                { name: 'tmp', mountPath: '/tmp' },
              ] + s3Irsa.volumeMounts,
            },
          ],
          securityContext: {
            runAsNonRoot: true,
            runAsUser: 65532,
            runAsGroup: 65532,
          },
          volumes: [
            { name: 'tmp', emptyDir: {} },
          ] + s3Irsa.volumes,
        },
      },
    },
  }
