{
  s3Env(role, controllerId, environment):
    local endpoint = 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333';
    local commonNames = [
      'AWS_ENDPOINT_URL_S3',
      'AWS_ENDPOINT_URL_STS',
      'AWS_ROLE_ARN',
      'AWS_WEB_IDENTITY_TOKEN_FILE',
      'AWS_REGION',
      'WORKER_S3_BUCKET',
      'WORKER_S3_PREFIX',
      'WORKER_CONTROLLER_ID',
      'AGR_WORKFLOW_UID',
    ];
    local presentNames = [entry.name for entry in environment if std.objectHas(entry, 'name')];
    local has(name) = std.member(presentNames, name);
    local optional(name, value) = if has(name) then [{ name: name, value: value }] else [];
    optional('AWS_ENDPOINT_URL_S3', endpoint) +
    optional('AWS_ENDPOINT_URL_STS', endpoint) +
    optional('AWS_ROLE_ARN', 'arn:aws:iam::role/' + role) +
    optional(
      'AWS_WEB_IDENTITY_TOKEN_FILE',
      '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token'
    ) +
    optional('AWS_REGION', 'us-east-1') +
    optional('WORKER_S3_BUCKET', 'agr-ai') +
    optional('WORKER_S3_PREFIX', 'worker-runs') +
    optional('WORKER_CONTROLLER_ID', controllerId) +
    optional('AGR_WORKFLOW_UID', '{{workflow.uid}}') +
    std.filter(
      function(entry) !std.objectHas(entry, 'name') || !std.member(commonNames, entry.name),
      environment
    ),
  securityContext: {
    allowPrivilegeEscalation: false,
    capabilities: { drop: ['ALL'] },
    readOnlyRootFilesystem: true,
    runAsGroup: 10001,
    runAsNonRoot: true,
    runAsUser: 10001,
  },
  volumeMounts: [
    {
      name: 'sts-token',
      mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
      readOnly: true,
    },
    { name: 'tmp', mountPath: '/tmp' },
  ],
  volumes(tmpSize): [
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
    { name: 'tmp', emptyDir: { sizeLimit: tmpSize } },
  ],
}
