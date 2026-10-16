local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local name = app.name + '-worker';
local externalSecret = import 'external-secret.jsonnet';
local s3Credentials = (import '../../components/seaweedfs-s3-credentials.libsonnet')('horse');
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: name,
    namespace: app.namespace,
    labels: labels(name),
    annotations: { 'argocd.argoproj.io/sync-wave': '2' },
  },
  spec: {
    replicas: 1,
    selector: { matchLabels: labels(name) },
    template: {
      metadata: {
        labels: labels(name),
      },
      spec: {
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 10001,
          runAsGroup: 10001,
          seccompProfile: { type: 'RuntimeDefault' },
        },
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        dnsConfig: { options: [{ name: 'ndots', value: '1' }] },
        volumes: [{ name: 'tmp', emptyDir: { sizeLimit: '2Gi' } }],
        containers: [
          container {
            name: 'worker',
            image: 'ghcr.io/walnuts1018/horse:v0.0.980@sha256:ee55d878dfdfb8fa5dd0d9e65d03e426ddb006139d3c67c5ffa3c5a14a77298b',
            imagePullPolicy: 'IfNotPresent',
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: { drop: ['ALL'] },
              readOnlyRootFilesystem: true,
            },
            command: ['/app/worker'],
            ports: [{ name: 'health', containerPort: 8081 }],
            env: [
              { name: 'OTEL_EXPORTER_OTLP_ENDPOINT', value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4318' },
              { name: 'OTEL_EXPORTER_OTLP_INSECURE', value: 'true' },
              { name: 'S3_ENDPOINT', value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333' },
              { name: 'S3_BUCKET', value: 'horse' },
              { name: 'OCR_URL', value: 'http://horse-ocr.horse.svc.cluster.local:8000' },
              { name: 'GEMINI_ENABLED', value: 'true' },
              {
                name: 'GEMINI_MODEL_PRICES',
                valueFrom: { configMapKeyRef: { name: app.name + '-gemini-model-prices', key: 'GEMINI_MODEL_PRICES' } },
              },
              {
                name: 'DATABASE_URL',
                valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'DATABASE_URL' } },
              },
              {
                name: 'RABBITMQ_URL',
                valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'RABBITMQ_URL' } },
              },
              {
                name: 'GEMINI_FREE_API_KEY',
                valueFrom: { secretKeyRef: { name: 'horse-ai', key: 'GEMINI_FREE_API_KEY', optional: true } },
              },
              {
                name: 'GEMINI_PAID_API_KEY',
                valueFrom: { secretKeyRef: { name: 'horse-ai', key: 'GEMINI_PAID_API_KEY', optional: true } },
              },
              {
                name: 'GEMINI_FREE_PROJECT_ID',
                valueFrom: { secretKeyRef: { name: 'horse-ai', key: 'GEMINI_FREE_PROJECT_ID', optional: true } },
              },
              {
                name: 'GEMINI_PAID_PROJECT_ID',
                valueFrom: { secretKeyRef: { name: 'horse-ai', key: 'GEMINI_PAID_PROJECT_ID', optional: true } },
              },
              {
                name: 'S3_ACCESS_KEY_ID',
                valueFrom: { secretKeyRef: { name: s3Credentials.secretName, key: s3Credentials.accessKeyField } },
              },
              {
                name: 'S3_SECRET_ACCESS_KEY',
                valueFrom: { secretKeyRef: { name: s3Credentials.secretName, key: s3Credentials.secretKeyField } },
              },
              {
                name: 'EMAIL_BODY_ENCRYPTION_KEYS',
                valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'EMAIL_BODY_ENCRYPTION_KEYS' } },
              },
            ],
            volumeMounts: [{ name: 'tmp', mountPath: '/tmp' }],
            livenessProbe: {
              httpGet: { path: '/healthz', port: 'health' },
              periodSeconds: 10,
            },
            readinessProbe: {
              httpGet: { path: '/readyz', port: 'health' },
              periodSeconds: 5,
            },
            resources: {
              requests: { cpu: '100m', memory: '512Mi' },
              limits: { cpu: '2', memory: '2Gi' },
            },
          },
        ],
      },
    },
  },
}
