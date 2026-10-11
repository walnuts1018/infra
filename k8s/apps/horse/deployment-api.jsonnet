local container = import '../../components/container.libsonnet';
local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local name = app.name + '-api';
local externalSecret = import 'external-secret.jsonnet';
local s3Credentials = (import '../../components/seaweedfs-s3-credentials.libsonnet')('horse');
local image = 'ghcr.io/walnuts1018/horse:latest';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: name,
    namespace: app.namespace,
    labels: labels(name),
  },
  spec: {
    replicas: 1,
    selector: { matchLabels: labels(name) },
    template: {
      metadata: { labels: labels(name) },
      spec: {
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        volumes: [{ name: 'tmp', emptyDir: { sizeLimit: '1Gi' } }],
        initContainers: [
          container {
            name: 'migrate',
            image: image,
            imagePullPolicy: 'Always',
            command: [
              '/usr/local/bin/atlas',
              'migrate',
              'apply',
              '--env',
              'kubernetes',
            ],
            env: [{
              name: 'DATABASE_URL',
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
            image: image,
            imagePullPolicy: 'Always',
            command: ['/app/api'],
            ports: [{ name: 'http', containerPort: 8080 }],
            volumeMounts: [{ name: 'tmp', mountPath: '/tmp' }],
            env: [
              { name: 'PORT', value: '8080' },
              { name: 'AUTO_MIGRATE', value: 'false' },
              { name: 'PUBLIC_ORIGIN', value: 'https://horse.walnuts.dev' },
              { name: 'OIDC_ISSUER_URL', value: 'https://zitadel.walnuts.dev' },
              { name: 'OIDC_REDIRECT_URL', value: 'https://horse.walnuts.dev/auth/callback' },
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
