local app = import 'app.json5';
local podSpecPatch = std.manifestJsonEx(import '_workflow_templates/pod-spec-patch.libsonnet', '', '', ':');
local stagePod = import '_workflow_templates/stage-pod.libsonnet';
{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'WorkflowTemplate',
  metadata: {
    name: 'agr-model-operation',
    namespace: app.namespace,
    labels: {
      'workflows.argoproj.io/archive-strategy': 'always',
    },
  },
  spec: {
    serviceAccountName: 'agr-workflow',
    executor: { serviceAccountName: 'agr-workflow-executor' },
    entrypoint: 'operate-model',
    synchronization: {
      mutexes: [{ name: 'agr-training' }],
    },
    activeDeadlineSeconds: 1800,
    ttlStrategy: { secondsAfterCompletion: 604800 },
    podGC: { strategy: 'OnWorkflowCompletion' },
    podMetadata: {
      labels: {
        app: 'agr-workflow',
        'app.kubernetes.io/name': 'agr-workflow',
      },
    },
    imagePullSecrets: [{ name: 'ghcr-login-secret' }],
    arguments: {
      parameters: [
        { name: 'operation' },
        { name: 'target-id' },
        { name: 'expected-revision' },
        { name: 'reason' },
        { name: 'operation-id' },
      ],
    },
    templates: [{
      name: 'operate-model',
      container: {
        image: 'ghcr.io/walnuts1018/agr-training:0.1.54@sha256:2afa6caeb2f0684957119e3a4683c1ca3f7a4838aef16d51ff2c1b40a0b4daec',
        command: ['/app/.venv/bin/agr-model-operation'],
        args: ['--operation', '{{workflow.parameters.operation}}', '--target-id', '{{workflow.parameters.target-id}}', '--expected-revision', '{{workflow.parameters.expected-revision}}', '--operation-id', '{{workflow.parameters.operation-id}}', '--reason', '{{workflow.parameters.reason}}'],
        env: stagePod.s3Env('agr-promoter', 'agr-promoter', [
          { name: 'AWS_ENDPOINT_URL_S3', value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333' },
          { name: 'AWS_ENDPOINT_URL_STS', value: 'https://seaweedfs.local.walnuts.dev' },
          { name: 'AWS_ROLE_ARN', value: 'arn:aws:iam::role/agr-promoter' },
          { name: 'AWS_WEB_IDENTITY_TOKEN_FILE', value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token' },
          { name: 'AWS_REGION', value: 'us-east-1' },
          { name: 'WORKER_S3_BUCKET', value: 'agr-ai' },
          { name: 'WORKER_S3_PREFIX', value: 'worker-runs' },
          { name: 'WORKER_CONTROLLER_ID', value: 'agr-promoter' },
          { name: 'AGR_WORKFLOW_UID', value: '{{workflow.uid}}' },
          { name: 'AGR_MODEL_OPERATION', value: '{{workflow.parameters.operation}}' },
          { name: 'SERVICE_ENDPOINT', value: 'http://agr-server.agr.svc.cluster.local:8080' },
          { name: 'SERVICE_GATEWAY_TOKEN', valueFrom: { secretKeyRef: { name: 'agr-learning-token', key: 'SERVICE_GATEWAY_TOKEN' } } },
        ]),
        resources: { requests: { cpu: '100m', memory: '256Mi', 'ephemeral-storage': '128Mi' }, limits: { cpu: '400m', memory: '896Mi', 'ephemeral-storage': '1Gi' } },
        securityContext: stagePod.securityContext,
        volumeMounts: stagePod.volumeMounts,
      },
      serviceAccountName: 'agr-promoter',
      volumes: stagePod.volumes('1Gi'),
      podSpecPatch: podSpecPatch,
    }],
  },
}
