{
  render(config):
    local job = {
      apiVersion: 'batch/v1',
      kind: 'Job',
      metadata: {
        name: 'agr-' + config.stage + '-{{workflow.name}}',
        namespace: 'agr',
        labels: {
          app: 'agr-learning',
          'app.kubernetes.io/name': 'agr-learning',
          'agr.walnuts.dev/stage': config.stageLabel,
        },
      },
      spec: {
        completionMode: 'Indexed',
        completions: '{{inputs.parameters.shard-count}}',
        parallelism: '{{inputs.parameters.' + config.parallelismParameter + '}}',
        backoffLimitPerIndex: 2,
        maxFailedIndexes: 0,
        activeDeadlineSeconds: 604800,
        ttlSecondsAfterFinished: 604800,
        template: {
          metadata: {
            labels: {
              app: 'agr-learning',
              'app.kubernetes.io/name': 'agr-learning',
              'agr.walnuts.dev/stage': config.stageLabel,
            },
          },
          spec: {
            serviceAccountName: config.serviceAccount,
            automountServiceAccountToken: false,
            restartPolicy: 'Never',
            priorityClassName: 'agr-learning',
            securityContext: {
              runAsNonRoot: true,
              runAsUser: 10001,
              runAsGroup: 10001,
              seccompProfile: { type: 'RuntimeDefault' },
            },
            imagePullSecrets: [{ name: 'ghcr-login-secret' }],
            volumes: [
              {
                name: 'learning-settings',
                configMap: { name: 'learning-settings' },
              },
              {
                name: 'sts-token',
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
              { name: 'tmp', emptyDir: { sizeLimit: '1Gi' } },
            ],
            containers: [{
              name: config.containerName,
              image: 'ghcr.io/walnuts1018/agr-worker:0.1.15@sha256:cc333251f3222e99e4efd94f67f584fa329eb6b8225a16d97ba1f77beeb105c9',
              command: ['worker'],
              args: [config.command] + config.commandArgs + [
                '--generation-id',
                '{{inputs.parameters.generation-id}}',
                '--config-sha256',
                '{{inputs.parameters.config-sha256}}',
                '--plan-uri',
                '{{inputs.parameters.plan-uri}}',
                '--shard-index',
                '$(JOB_COMPLETION_INDEX)',
                '--shard-count',
                '{{inputs.parameters.shard-count}}',
              ],
              env: [
                { name: 'AGR_WORKFLOW_UID', value: '{{workflow.uid}}' },
                {
                  name: 'AGR_WORKER_IMAGE_REFERENCE',
                  value: 'ghcr.io/walnuts1018/agr-worker:0.1.15@sha256:cc333251f3222e99e4efd94f67f584fa329eb6b8225a16d97ba1f77beeb105c9',
                },
                {
                  name: 'AWS_ENDPOINT_URL_S3',
                  value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
                },
                {
                  name: 'AWS_ENDPOINT_URL_STS',
                  value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
                },
                { name: 'AWS_ROLE_ARN', value: 'arn:aws:iam::role/' + config.controllerId },
                {
                  name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
                  value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
                },
                { name: 'AWS_REGION', value: 'us-east-1' },
                { name: 'WORKER_CONTROLLER_ID', value: config.controllerId },
                {
                  name: 'WORKER_S3_ENDPOINT',
                  value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333',
                },
                { name: 'WORKER_S3_BUCKET', value: 'agr-ai' },
                { name: 'WORKER_S3_PREFIX', value: 'worker-runs' },
                { name: 'SERVICE_ENDPOINT', value: 'http://agr-server.agr.svc.cluster.local:8080' },
                {
                  name: 'SERVICE_GATEWAY_TOKEN',
                  valueFrom: {
                    secretKeyRef: {
                      name: 'agr-learning-token',
                      key: 'SERVICE_GATEWAY_TOKEN',
                    },
                  },
                },
              ] + config.extraEnv,
              resources: {
                requests: {
                  cpu: '{{inputs.parameters.' + config.cpuLimitParameter + '}}',
                  memory: '{{inputs.parameters.actor-memory-limit}}Mi',
                  'ephemeral-storage': '128Mi',
                },
                limits: {
                  cpu: '{{inputs.parameters.' + config.cpuLimitParameter + '}}',
                  memory: '{{inputs.parameters.actor-memory-limit}}Mi',
                  'ephemeral-storage': '1Gi',
                },
              },
              securityContext: {
                readOnlyRootFilesystem: true,
                allowPrivilegeEscalation: false,
                capabilities: { drop: ['ALL'] },
              },
              volumeMounts: [
                { name: 'learning-settings', mountPath: '/etc/agr', readOnly: true },
                {
                  name: 'sts-token',
                  mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
                  readOnly: true,
                },
                { name: 'tmp', mountPath: '/tmp' },
              ],
            }],
          },
        },
      },
    };
    local manifest = std.manifestYamlDoc(job);
    local unquoteIntegerField(yaml, name, expression) =
      local quotedKey = '"' + name + '": "' + expression + '"';
      local unquotedKey = '"' + name + '": ' + expression;
      local yamlWithQuotedKeys = std.strReplace(yaml, quotedKey, unquotedKey);
      std.strReplace(
        yamlWithQuotedKeys,
        name + ': "' + expression + '"',
        name + ': ' + expression
      );
    unquoteIntegerField(
      unquoteIntegerField(manifest, 'completions', '{{inputs.parameters.shard-count}}'),
      'parallelism',
      '{{inputs.parameters.' + config.parallelismParameter + '}}'
    ),
}
