local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local externalSecret = import 'external-secret.jsonnet';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (labels)(app.name),
    },
    template: {
      metadata: {
        labels: (labels)(app.name),
      },
      spec: {
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'mpeg-dash-encoder',
            image: 'ghcr.io/walnuts1018/mpeg-dash-encoder:52054e17d80858a0d2c515601db0a6f189352cf4-14',
            ports: [
              {
                containerPort: 8080,
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/healthz',
                port: 8080,
              },
              failureThreshold: 1,
              initialDelaySeconds: 10,
              periodSeconds: 10,
            },
            env: [
              {
                name: 'LOG_LEVEL',
                value: 'debug',
              },
              {
                name: 'ADMIN_TOKEN',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'admin_token',
                  },
                },
              },
              {
                name: 'JWT_SIGN_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'jwt_sign_secret',
                  },
                },
              },
              {
                name: 'MINIO_ENDPOINT',
                value: 'minio.minio.svc.cluster.local:9000',
              },
              {
                name: 'MINIO_ACCESS_KEY',
                value: 'k1KHQ1COSPXdYb3CBDUJ',
              },
              {
                name: 'MINIO_SECRET_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'minio_secret_key',
                  },
                },
              },
              {
                name: 'MINIO_BUCKET',
                value: 'mucaron',
              },
              {
                name: 'MINIO_REGION',
                value: 'ap-northeast-1',
              },
              {
                name: 'MINIO_USE_SSL',
                value: 'false',
              },
              {
                name: 'FFMPEG_HW_ACCEL',
                value: 'qsv',
              },
              {
                name: 'MINIO_SOURCE_UPLOAD_BUCKET',
                value: 'mpeg-dash-encoder-source-upload',
              },
              {
                name: 'MINIO_OUTPUT_BUCKET',
                value: 'mpeg-dash-encoder-output',
              },
              {
                name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
                value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317',
              },
            ],
            volumeMounts: [
              {
                mountPath: '/tmp',
                name: 'tmp',
              },
              {
                mountPath: '/var/log/mpeg-dash-encoder',
                name: 'log',
              },
            ],
            resources: {
            },
          }, {
            securityContext: {
              privileged: true,
            },
          }),
        ],
        volumes: [
          {
            name: 'tmp',
            emptyDir: {},
          },
          {
            name: 'log',
            emptyDir: {},
          },
        ],
        nodeSelector: {
          'kubernetes.io/hostname': 'cake',
        },
      },
    },
  },
}
