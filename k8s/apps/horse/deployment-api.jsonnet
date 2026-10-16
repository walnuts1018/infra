local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local name = app.name + '-api';
local externalSecret = import 'external-secret.jsonnet';
local s3Credentials = (import '../../components/seaweedfs-s3-credentials.libsonnet')('horse');
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: name,
    namespace: app.namespace,
    labels: labels(name),
    annotations: {
      'argocd.argoproj.io/sync-wave': '0',
      'reloader.stakater.com/auto': 'true',
    },
  },
  spec: {
    replicas: 1,
    selector: { matchLabels: labels(name) },
    template: {
      metadata: { labels: labels(name) },
      spec: {
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 10001,
          runAsGroup: 10001,
          seccompProfile: { type: 'RuntimeDefault' },
        },
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        volumes: [
          { name: 'tmp', emptyDir: { sizeLimit: '1Gi' } },
          {
            name: 'local-ca-bundle',
            configMap: {
              name: 'local-ca-bundle',
              items: [{ key: 'trust-bundle.pem', path: 'trust-bundle.pem' }],
            },
          },
        ],
        initContainers: [
          container {
            name: 'migrate',
            image: 'ghcr.io/walnuts1018/horse:v0.0.1002@sha256:b384b07cb773a0f6c0f3df86fc32ac649511e1f13199b3294135042b1ec10e80',
            imagePullPolicy: 'IfNotPresent',
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: { drop: ['ALL'] },
              readOnlyRootFilesystem: true,
            },
            command: [
              '/usr/local/bin/atlas',
              'migrate',
              'apply',
              '--config',
              'file:///app/atlas-rust.hcl',
              '--env',
              'rust',
            ],
            env: [{
              name: 'RUST_DATABASE_URL',
              valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'DATABASE_URL' } },
            }],
            resources: {
              requests: { cpu: '10m', memory: '64Mi' },
              limits: { cpu: '500m', memory: '256Mi' },
            },
          },
        ],
        containers: [
          container {
            name: 'api',
            image: 'ghcr.io/walnuts1018/horse:v0.0.1002@sha256:b384b07cb773a0f6c0f3df86fc32ac649511e1f13199b3294135042b1ec10e80',
            imagePullPolicy: 'IfNotPresent',
            command: ['/app/api'],
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: { drop: ['ALL'] },
              readOnlyRootFilesystem: true,
            },
            ports: [{ name: 'http', containerPort: 8080 }],
            volumeMounts: [
              { name: 'tmp', mountPath: '/tmp' },
              {
                name: 'local-ca-bundle',
                mountPath: '/etc/ssl/certs/trust-bundle.pem',
                subPath: 'trust-bundle.pem',
                readOnly: true,
              },
            ],
            env: [
              { name: 'PORT', value: '8080' },
              { name: 'AUTO_MIGRATE', value: 'false' },
              { name: 'PUBLIC_ORIGIN', value: 'https://horse.walnuts.dev' },
              { name: 'OIDC_ISSUER_URL', value: 'https://auth.walnuts.dev' },
              { name: 'OIDC_REDIRECT_URL', value: 'https://horse.walnuts.dev/auth/callback' },
              { name: 'OCR_URL', value: 'http://horse-ocr.horse.svc.cluster.local:8000' },
              { name: 'OTEL_EXPORTER_OTLP_ENDPOINT', value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4318' },
              { name: 'OTEL_EXPORTER_OTLP_INSECURE', value: 'true' },
              { name: 'SSL_CERT_FILE', value: '/etc/ssl/certs/trust-bundle.pem' },
              { name: 'S3_ENDPOINT', value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333' },
              { name: 'S3_BUCKET', value: 'horse' },
              {
                name: 'DATABASE_URL',
                valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'DATABASE_URL' } },
              },
              {
                name: 'OIDC_CLIENT_ID',
                valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'OIDC_CLIENT_ID' } },
              },
              {
                name: 'OIDC_CLIENT_SECRET',
                valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'OIDC_CLIENT_SECRET' } },
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
                name: 'RABBITMQ_URL',
                valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'RABBITMQ_URL' } },
              },
              {
                name: 'EMAIL_BODY_ENCRYPTION_KEYS',
                valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'EMAIL_BODY_ENCRYPTION_KEYS' } },
              },
            ],
            livenessProbe: {
              httpGet: { path: '/healthz', port: 'http' },
              periodSeconds: 10,
            },
            readinessProbe: {
              httpGet: { path: '/readyz', port: 'http' },
              periodSeconds: 5,
            },
            resources: {
              requests: { cpu: '25m', memory: '128Mi' },
              limits: { cpu: '1000m', memory: '1Gi' },
            },
          },
        ],
      },
    },
  },
}
