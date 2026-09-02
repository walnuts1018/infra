local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local commonEnv = import '../env.libsonnet';
local externalSecret = import '../external-secret.jsonnet';
local s3Irsa = import '../s3-irsa.libsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-embedding-worker',
    namespace: app.namespace,
    labels: labels(app.name + '-embedding-worker'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name + '-embedding-worker'),
    },
    template: {
      metadata: {
        labels: labels(app.name + '-embedding-worker'),
      },
      spec: {
        serviceAccountName: (import '../sa.jsonnet').metadata.name,
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'embedding-worker',
            image: 'ghcr.io/walnuts1018/picca/embedding-worker:v0.0.47',
            imagePullPolicy: 'IfNotPresent',
            envFrom: [
              { secretRef: { name: externalSecret.spec.target.name } },
            ],
            env: commonEnv + s3Irsa.env + [
              {
                name: 'OTEL_SERVICE_NAME',
                value: 'picca-embedding-worker',
              },
            ],
            resources: {
              requests: {
                cpu: '250m',
                memory: '256Mi',
              },
              limits: {
                cpu: '1',
                memory: '512Mi',
              },
            },
            ports: [
              {
                containerPort: 8080,
                name: 'health',
              },
            ],
            startupProbe: {
              httpGet: {
                path: '/healthz',
                port: 8080,
              },
              periodSeconds: 10,
              failureThreshold: 18,
            },
            livenessProbe: {
              httpGet: {
                path: '/healthz',
                port: 8080,
              },
              periodSeconds: 15,
              failureThreshold: 3,
            },
            volumeMounts: [
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
            ] + s3Irsa.volumeMounts,
          },
        ],
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 65532,
          runAsGroup: 65532,
        },
        volumes: [
          { name: 'tmp', emptyDir: {} },
        ] + s3Irsa.volumes,
      },
    },
  },
}
