local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local workerToken = import 'external-secret-learning-token.jsonnet';
local learningServiceAccount = import 'service-account-learning.jsonnet';
{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: app.name + '-learning',
    namespace: app.namespace,
    labels: labels(app.name + '-learning'),
  },
  spec: {
    schedule: '0 3 * * *',
    timeZone: 'Asia/Tokyo',
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 3600,
    successfulJobsHistoryLimit: 3,
    failedJobsHistoryLimit: 3,
    jobTemplate: {
      spec: {
        backoffLimit: 0,
        activeDeadlineSeconds: 604800,
        ttlSecondsAfterFinished: 604800,
        template: {
          metadata: {
            labels: labels(app.name + '-learning'),
          },
          spec: {
            serviceAccountName: learningServiceAccount.metadata.name,
            automountServiceAccountToken: false,
            imagePullSecrets: [{ name: 'ghcr-login-secret' }],
            restartPolicy: 'Never',
            securityContext: {
              runAsNonRoot: true,
              runAsUser: 10001,
              runAsGroup: 10001,
              fsGroup: 10001,
              seccompProfile: { type: 'RuntimeDefault' },
            },
            volumes: [
              { name: 'tmp', emptyDir: { sizeLimit: '8Gi' } },
              {
                name: 'seaweedfs-sts-token',
                projected: {
                  sources: [{
                    serviceAccountToken: {
                      audience: 'sts.seaweedfs.com',
                      expirationSeconds: 3600,
                      path: 'token',
                    },
                  }],
                },
              },
            ],
            containers: [
              (import '../../components/container.libsonnet') {
                name: 'learning-pipeline',
                image: 'ghcr.io/walnuts1018/agr-training:0.1.2@sha256:d8a28bd7710e692905e3e677ac1ff3a5f02ff8198acdcd93e6f5cf55a8a9f2f9',
                imagePullPolicy: 'IfNotPresent',
                command: ['/app/.venv/bin/agr-pipeline-run'],
                env: [
                  { name: 'AGR_PIPELINE_JOB_UID', valueFrom: { fieldRef: { fieldPath: 'metadata.uid' } } },
                  { name: 'SERVICE_ENDPOINT', value: 'http://agr-server.agr.svc.cluster.local:8080' },
                  { name: 'SERVICE_GATEWAY_TOKEN', valueFrom: { secretKeyRef: { name: workerToken.spec.target.name, key: 'SERVICE_GATEWAY_TOKEN' } } },
                  { name: 'WORKER_CONTROLLER_ID', value: 'agr-learning-job' },
                  { name: 'AGR_SERVER_SERVICE_HEALTH_URL', value: 'http://agr-server.agr.svc.cluster.local:8081' },
                  { name: 'WORKER_S3_BUCKET', value: 'agr-ai' },
                  { name: 'WORKER_S3_PREFIX', value: 'worker-runs' },
                  { name: 'WORKER_S3_ENDPOINT', value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333' },
                  { name: 'AWS_ENDPOINT_URL_S3', value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333' },
                  { name: 'AWS_ENDPOINT_URL_STS', value: 'https://seaweedfs.local.walnuts.dev' },
                  { name: 'AWS_REGION', value: 'us-east-1' },
                  { name: 'AWS_ROLE_ARN', value: 'arn:aws:iam::role/agr-learning-job' },
                  { name: 'AWS_WEB_IDENTITY_TOKEN_FILE', value: '/projected/sts.seaweedfs.com/serviceaccount/token' },
                  { name: 'AGR_MODEL_ACTIVE_POINTER_S3_URI', value: 's3://agr-ai/worker-runs/models/active.json' },
                  { name: 'AGR_PIPELINE_BOOTSTRAP_RESAMPLES', value: '10000' },
                  { name: 'AGR_PIPELINE_SIMULATION_CONCURRENCY', value: '4' },
                  { name: 'AGR_PIPELINE_ANALYSIS_ROLLOUTS', value: '8' },
                  { name: 'AGR_PIPELINE_ANALYSIS_DURATION_MS', value: '100' },
                  { name: 'PYTHONDONTWRITEBYTECODE', value: '1' },
                  { name: 'PYTHONHASHSEED', value: '0' },
                  { name: 'HOME', value: '/tmp' },
                  { name: 'RUST_BACKTRACE', value: '1' },
                ],
                resources: {
                  requests: { cpu: '2', memory: '8Gi' },
                  limits: { cpu: '8', memory: '24Gi' },
                },
                volumeMounts: [
                  { name: 'tmp', mountPath: '/tmp' },
                  { name: 'seaweedfs-sts-token', mountPath: '/projected/sts.seaweedfs.com/serviceaccount', readOnly: true },
                ],
              },
            ],
          },
        },
      },
    },
  },
}
