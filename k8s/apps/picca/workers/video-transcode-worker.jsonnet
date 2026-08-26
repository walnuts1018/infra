local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local commonEnv = import '../env.libsonnet';
local externalSecret = import '../external-secret.jsonnet';
local plans = import '../plans.libsonnet';
local s3Irsa = import '../s3-irsa.libsonnet';
local scyllaTls = import '../scylla-tls.libsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-video-transcode-worker',
    namespace: app.namespace,
    labels: labels(app.name + '-video-transcode-worker'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: labels(app.name + '-video-transcode-worker'),
    },
    template: {
      metadata: {
        labels: labels(app.name + '-video-transcode-worker'),
      },
      spec: {
        serviceAccountName: (import '../sa.jsonnet').metadata.name,
        imagePullSecrets: [{ name: 'ghcr-login-secret' }],
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'video-transcode-worker',
            image: 'ghcr.io/walnuts1018/picca/video-transcode-worker:v0.0.32',
            imagePullPolicy: 'IfNotPresent',
            envFrom: [
              { secretRef: { name: externalSecret.spec.target.name } },
            ],
            env: commonEnv + s3Irsa.env + scyllaTls.env + plans.env + [
              {
                name: 'OTEL_SERVICE_NAME',
                value: 'picca-video-transcode-worker',
              },
            ],
            resources: {
              requests: {
                cpu: '1',
                memory: '1Gi',
              },
              limits: {
                cpu: '4',
                memory: '2Gi',
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
            ] + s3Irsa.volumeMounts + scyllaTls.volumeMounts + plans.volumeMounts,
          },
        ],
        securityContext: {
          runAsNonRoot: true,
          runAsUser: 65532,
          runAsGroup: 65532,
        },
        volumes: [
          { name: 'tmp', emptyDir: {} },
        ] + s3Irsa.volumes + scyllaTls.volumes + plans.volumes,
      },
    },
  },
}
