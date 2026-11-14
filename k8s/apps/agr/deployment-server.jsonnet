local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local database = import 'external-secret.jsonnet';
local sa = import 'service-account-app.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-server',
    namespace: app.namespace,
    labels: labels(app.name + '-server'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name + '-server'),
    },
    template: {
      metadata: {
        labels: labels(app.name + '-server'),
      },
      spec: {
        automountServiceAccountToken: false,
        serviceAccountName: sa.metadata.name,
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        securityContext: {
          runAsUser: 65532,
          runAsGroup: 65532,
          fsGroup: 65532,
          seccompProfile: { type: 'RuntimeDefault' },
        },
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'app-service',
            image: 'ghcr.io/walnuts1018/agr-server:0.1.2@sha256:18f0dedb798adcdc443bbcbc0f0a04a5b280327d7eae834952e063ff0c29caec',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              { name: 'grpc-web', containerPort: 8080, protocol: 'TCP' },
              { name: 'health', containerPort: 8081, protocol: 'TCP' },
            ],
            envFrom: [
              { secretRef: { name: database.spec.target.name } },
            ],
            env: [
              { name: 'SERVICE_LISTEN_ADDR', value: '0.0.0.0:8080' },
              { name: 'SERVICE_HEALTH_ADDR', value: '0.0.0.0:8081' },
              { name: 'AGR_LEARNING_JOB_IDENTITIES', value: 'agr-learning-job' },
              { name: 'AGR_POLICY_MODEL_S3_URI', value: 's3://agr-ai/worker-runs/models/active.json' },
              { name: 'WORKER_S3_BUCKET', value: 'agr-ai' },
              { name: 'AWS_ENDPOINT_URL_S3', value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333' },
              { name: 'AWS_ENDPOINT_URL_STS', value: 'https://seaweedfs.local.walnuts.dev' },
              { name: 'AWS_REGION', value: 'us-east-1' },
              { name: 'AWS_ROLE_ARN', value: 'arn:aws:iam::role/agr-app-service' },
              { name: 'AWS_WEB_IDENTITY_TOKEN_FILE', value: '/projected/sts.seaweedfs.com/serviceaccount/token' },
              { name: 'RUST_BACKTRACE', value: '1' },
              { name: 'OTEL_EXPORTER_OTLP_ENDPOINT', value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317' },
            ],
            resources: {
              requests: { cpu: '100m', memory: '256Mi' },
              limits: { cpu: '2', memory: '2Gi' },
            },
            startupProbe: {
              httpGet: { path: '/livez', port: 'health' },
              periodSeconds: 5,
              timeoutSeconds: 2,
              failureThreshold: 60,
            },
            livenessProbe: {
              httpGet: { path: '/livez', port: 'health' },
              periodSeconds: 20,
              timeoutSeconds: 2,
            },
            readinessProbe: {
              httpGet: { path: '/readyz', port: 'health' },
              periodSeconds: 10,
              timeoutSeconds: 3,
            },
            volumeMounts: [
              { name: 'tmp', mountPath: '/tmp' },
              { name: 'seaweedfs-sts-token', mountPath: '/projected/sts.seaweedfs.com/serviceaccount', readOnly: true },
            ],
          }, {
            securityContext: {
              runAsNonRoot: true,
              allowPrivilegeEscalation: false,
            },
          }),
        ],
        volumes: [
          { name: 'tmp', emptyDir: {} },
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
      },
    },
  },
}
