{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
      },
      spec: {
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'mpeg-dash-encoder',
            image: 'ghcr.io/walnuts1018/mpeg-dash-encoder:2274ab364149ca08bf3a826b99435a83ab8832d3-3',
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
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'admin_token',
                  },
                },
              },
              {
                name: 'JWT_SIGN_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
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
                value: 'OXx9ohSJy0zqcqu2o98k',
              },
              {
                name: 'MINIO_SECRET_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
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
                value: 'true',
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
      },
    },
  },
}
