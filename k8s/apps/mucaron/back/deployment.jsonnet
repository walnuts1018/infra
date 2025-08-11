{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import '../app.json5').name + '-back',
    namespace: (import '../app.json5').namespace,
    labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-back' },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-back' },
    },
    template: {
      metadata: {
        labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-back' },
      },
      spec: {
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'mucaron-backend',
            image: 'ghcr.io/walnuts1018/mucaron-backend:c8675c77b41b7155943b6316448ae856beea214f-88',
            ports: [
              {
                containerPort: 8080,
              },
            ],
            resources: {
              requests: {
                cpu: '10m',
                memory: '100Mi',
              },
              limits: {
                cpu: '2',
                memory: '2Gi',
              },
            },
            env: [
              {
                name: 'SERVER_ENDPOINT',
                value: 'https://mucaron.walnuts.dev',
              },
              {
                name: 'PSQL_HOST',
                value: 'postgresql-default-rw.databases.svc.cluster.local',
              },
              {
                name: 'PSQL_PORT',
                value: '5432',
              },
              {
                name: 'PSQL_DATABASE',
                value: 'mucaron',
              },
              {
                name: 'PSQL_USER',
                value: 'mucaron',
              },
              {
                name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
                value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317',
              },
              {
                name: 'OTEL_EXPORTER_OTLP_INSECURE',
                value: 'true',
              },
              {
                name: 'PSQL_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'postgres_password',
                  },
                },
              },
              {
                name: 'PSQL_SSLMODE',
                value: 'disable',
              },
              {
                name: 'MINIO_ENDPOINT',
                value: 'minio.walnuts.dev',
              },
              {
                name: 'MINIO_ACCESS_KEY',
                value: '4SYRxLsspRxsvXvaddkz',
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
                name: 'REDIS_HOST',
                value: 'mucaron-redis',
              },
              {
                name: 'REDIS_PORT',
                value: '6379',
              },
              {
                name: 'REDIS_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'redis_password',
                  },
                },
              },
              {
                name: 'SESSION_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'session_secret',
                  },
                },
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/healthz',
                port: 8080,
              },
              initialDelaySeconds: 10,
              periodSeconds: 10,
              timeoutSeconds: 5,
              failureThreshold: 3,
            },
            readinessProbe: {
              httpGet: {
                path: '/healthz',
                port: 8080,
              },
              initialDelaySeconds: 10,
              periodSeconds: 10,
              timeoutSeconds: 5,
              failureThreshold: 3,
            },
            volumeMounts: [
              {
                name: 'mucaron-log',
                mountPath: '/var/log/mucaron',
              },
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
            ],
          },
        ],
        nodeSelector: {
          'kubernetes.io/arch': 'amd64',
        },
        volumes: [
          {
            name: 'mucaron-log',
            emptyDir: {},
          },
          {
            name: 'tmp',
            persistentVolumeClaim: {
              claimName: (import 'pvc.jsonnet').metadata.name,
            },
          },
        ],
      },
    },
  },
}
