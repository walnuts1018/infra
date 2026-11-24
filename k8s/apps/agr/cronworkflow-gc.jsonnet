local stagePod = import '_workflow_templates/stage-pod.libsonnet';
local app = import 'app.json5';
local podSpecPatch = std.manifestJsonEx(import '_workflow_templates/pod-spec-patch.libsonnet', '', '', ':');
local image = 'ghcr.io/walnuts1018/agr-training:0.1.63@sha256:98791f3f89eb2d29a9b0ee961ea73f94e909c15401b613ee0be99389828d8d0e';
{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'CronWorkflow',
  metadata: {
    name: 'agr-gc',
    namespace: app.namespace,
    labels: {
      'workflows.argoproj.io/archive-strategy': 'always',
    },
  },
  spec: {
    schedules: ['0 4 * * *'],
    timezone: 'Asia/Tokyo',
    concurrencyPolicy: 'Forbid',
    startingDeadlineSeconds: 3600,
    suspend: false,
    successfulJobsHistoryLimit: 3,
    failedJobsHistoryLimit: 10,
    workflowSpec: {
      entrypoint: 'gc',
      // A hung storage cleanup must not suppress every later scheduled run.
      activeDeadlineSeconds: 7200,
      serviceAccountName: 'agr-gc',
      executor: { serviceAccountName: 'agr-workflow-executor' },
      imagePullSecrets: [{ name: 'ghcr-login-secret' }],
      podGC: { strategy: 'OnWorkflowCompletion' },
      podMetadata: {
        labels: {
          app: 'agr-learning',
          'app.kubernetes.io/name': 'agr-learning',
        },
      },
      ttlStrategy: { secondsAfterCompletion: 604800 },
      templates: [{
        name: 'gc',
        podSpecPatch: podSpecPatch,
        container: {
          image: image,
          command: ['/app/.venv/bin/agr-gc-execute'],
          args: ['--retention-days', '15'],
          env: stagePod.s3Env('agr-gc', 'agr-gc', [
            { name: 'AWS_ENDPOINT_URL_S3', value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333' },
            { name: 'AWS_ENDPOINT_URL_STS', value: 'https://seaweedfs.local.walnuts.dev' },
            { name: 'AWS_ROLE_ARN', value: 'arn:aws:iam::role/agr-gc' },
            { name: 'AWS_WEB_IDENTITY_TOKEN_FILE', value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token' },
            { name: 'AWS_REGION', value: 'us-east-1' },
            { name: 'WORKER_S3_ENDPOINT', value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333' },
            { name: 'WORKER_S3_BUCKET', value: 'agr-ai' },
            { name: 'WORKER_S3_PREFIX', value: 'worker-runs' },
            { name: 'WORKER_CONTROLLER_ID', value: 'agr-gc' },
            { name: 'AGR_WORKFLOW_UID', value: '{{workflow.uid}}' },
            { name: 'AGR_GC_RETENTION_DAYS', value: '15' },
            { name: 'SERVICE_ENDPOINT', value: 'http://agr-server.agr.svc.cluster.local:8080' },
            {
              name: 'SERVICE_GATEWAY_TOKEN',
              valueFrom: { secretKeyRef: { name: 'agr-learning-token', key: 'SERVICE_GATEWAY_TOKEN' } },
            },
          ]),
          resources: {
            requests: { cpu: '100m', memory: '256Mi', 'ephemeral-storage': '128Mi' },
            limits: { cpu: '500m', memory: '1Gi', 'ephemeral-storage': '1Gi' },
          },
          securityContext: stagePod.securityContext,
          volumeMounts: stagePod.volumeMounts,
        },
        volumes: stagePod.volumes('1Gi'),
      }],
    },
  },
}
