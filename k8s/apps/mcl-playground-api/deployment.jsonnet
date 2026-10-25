local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local externalSecret = import 'external-secret.jsonnet';
local s3Credentials = (import 's3-config.libsonnet').forIdentity('mcl_playground');
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name),
    },
    template: {
      metadata: {
        labels: labels(app.name),
      },
      spec: {
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        automountServiceAccountToken: false,
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 65532,
          runAsGroup: 65532,
          seccompProfile: {
            type: 'RuntimeDefault',
          },
        },
        initContainers: [
          {
            name: 'migrate',
            image: 'ghcr.io/manifest-configuration-language/website-api:main@sha256:63048868554b8a1a3189994c67980e33d11961dbb40a423d8a54a27a4e7fc57c',
            imagePullPolicy: 'IfNotPresent',
            command: ['node', 'src/api/migrate.js'],
            env: [
              {
                name: 'DATABASE_URL',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'DATABASE_URL',
                  },
                },
              },
            ],
            resources: {
              requests: { cpu: '10m', memory: '64Mi' },
              limits: { memory: '128Mi' },
            },
            securityContext: {
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: true,
              capabilities: { drop: ['ALL'] },
            },
          },
        ],
        containers: [
          {
            name: 'api',
            image: 'ghcr.io/manifest-configuration-language/website-api:main@sha256:63048868554b8a1a3189994c67980e33d11961dbb40a423d8a54a27a4e7fc57c',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                name: 'http',
                containerPort: 8080,
              },
            ],
            env: [
              { name: 'HOST', value: '0.0.0.0' },
              { name: 'PORT', value: '8080' },
              {
                name: 'DATABASE_URL',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'DATABASE_URL',
                  },
                },
              },
              { name: 'VALKEY_URL', value: 'redis://valkey-mcl-playground-api-valkey.mcl-website.svc.cluster.local:6379' },
              { name: 'S3_ENDPOINT', value: 'http://seaweedfs-default-s3.seaweedfs.svc.cluster.local:8333' },
              { name: 'S3_BUCKET', value: 'mcl-playground' },
              { name: 'S3_REGION', value: 'us-east-1' },
              { name: 'MCL_RUNTIME_VERSION', value: '0.3.11' },
              { name: 'SHARE_TTL_DAYS', value: '90' },
              { name: 'SHARE_STORAGE_MAX_BYTES', value: '10737418240' },
              { name: 'SHARE_DAILY_UPLOAD_BYTES', value: '134217728' },
              {
                name: 'S3_ACCESS_KEY_ID',
                valueFrom: { secretKeyRef: { name: s3Credentials.secretName, key: s3Credentials.accessKeyField } },
              },
              {
                name: 'S3_SECRET_ACCESS_KEY',
                valueFrom: { secretKeyRef: { name: s3Credentials.secretName, key: s3Credentials.secretKeyField } },
              },
              {
                name: 'RATE_LIMIT_HMAC_SECRET',
                valueFrom: { secretKeyRef: { name: externalSecret.spec.target.name, key: 'RATE_LIMIT_HMAC_SECRET' } },
              },
            ],
            readinessProbe: {
              httpGet: {
                path: '/healthz',
                port: 'http',
              },
              periodSeconds: 10,
              timeoutSeconds: 2,
            },
            livenessProbe: {
              httpGet: {
                path: '/healthz',
                port: 'http',
              },
              periodSeconds: 20,
              timeoutSeconds: 2,
            },
            resources: {
              requests: {
                cpu: '10m',
                memory: '64Mi',
              },
              limits: {
                memory: '384Mi',
              },
            },
            securityContext: {
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: true,
              capabilities: {
                drop: ['ALL'],
              },
            },
          },
        ],
      },
    },
  },
}
