{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'debug-web',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-debug-web'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')('picca-ai-prototype-debug-web'),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-debug-web'),
      },
      spec: {
        serviceAccountName: (import 'debug-web-serviceaccount.jsonnet').metadata.name,
        imagePullSecrets: [
          { name: 'ghcr-login-secret' },
        ],
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'debug-web',
            image: 'ghcr.io/walnuts1018/picca-ai-prototype-debug-web:latest',
            imagePullPolicy: 'Always',
            ports: [
              {
                name: 'http',
                containerPort: 8080,
              },
            ],
            env: [
              {
                name: 'DEBUG_WEB_HOST',
                value: '0.0.0.0',
              },
              {
                name: 'DEBUG_WEB_PORT',
                value: '8080',
              },
              {
                name: 'GATEWAY_BASE_URL',
                value: 'http://gateway:8000',
              },
              {
                name: 'SQLITE_PATH',
                value: '/data/debug-web.sqlite',
              },
              {
                name: 'STATUS_POLL_INTERVAL_MS',
                value: '3000',
              },
              {
                name: 'SEARCH_TIMEOUT_SECONDS',
                value: '30',
              },
              {
                name: 'UPLOAD_OBJECT_PREFIX',
                value: 'debug/',
              },
              {
                name: 'MAX_UPLOAD_SIZE_MB',
                value: '64',
              },
              {
                name: 'RABBITMQ_URL',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret-rabbitmq-app-user.jsonnet').spec.target.name,
                    key: 'amqp_url',
                  },
                },
              },
              {
                name: 'RABBITMQ_QUEUE',
                value: 'picca_prototype_image_jobs',
              },
              {
                name: 'RABBITMQ_RESULT_QUEUE',
                value: 'picca_prototype_image_job_results',
              },
              {
                name: 'S3_ENDPOINT_URL',
                value: 'https://seaweedfs.local.walnuts.dev',
              },
              {
                name: 'S3_BUCKET',
                value: 'picca_ai_prototype',
              },
              {
                name: 'AWS_WEB_IDENTITY_TOKEN_FILE',
                value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token',
              },
              {
                name: 'AWS_ENDPOINT_URL_STS',
                value: 'https://seaweedfs.local.walnuts.dev',
              },
              {
                name: 'AWS_ENDPOINT_URL_S3',
                value: 'https://seaweedfs.local.walnuts.dev',
              },
              {
                name: 'AWS_REGION',
                value: 'us-east-1',
              },
              {
                name: 'AWS_ROLE_ARN',
                value: 'arn:aws:iam::role/picca-ai-prototype-debug-web',
              },
            ],
            resources: {
              requests: {
                cpu: '10m',
                memory: '128Mi',
              },
              limits: {
                cpu: '1',
                memory: '1Gi',
              },
            },
            volumeMounts: [
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
              {
                name: 'debug-web-data',
                mountPath: '/data',
              },
              {
                name: 'seaweedfs-sts-token',
                mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
                readOnly: true,
              },
            ],
          }, {
            securityContext: {
              allowPrivilegeEscalation: false,
              capabilities: {
                add: [
                  'NET_BIND_SERVICE',
                ],
                drop: [
                  'all',
                ],
              },
              readOnlyRootFilesystem: false,
              seccompProfile: {
                type: 'RuntimeDefault',
              },
            },
          }),
        ],
        volumes: [
          {
            name: 'tmp',
            emptyDir: {},
          },
          {
            name: 'debug-web-data',
            persistentVolumeClaim: {
              claimName: (import 'debug-web-pvc.jsonnet').metadata.name,
            },
          },
          {
            name: 'seaweedfs-sts-token',
            projected: {
              sources: [
                {
                  serviceAccountToken: {
                    audience: 'sts.seaweedfs.com',
                    expirationSeconds: 86400,
                    path: 'token',
                  },
                },
              ],
            },
          },
        ],
      },
    },
  },
}
