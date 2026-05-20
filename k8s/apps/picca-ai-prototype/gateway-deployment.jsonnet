{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'gateway',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-gateway'),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')('picca-ai-prototype-gateway'),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-gateway'),
      },
      spec: {
        serviceAccountName: (import 'serviceaccount.jsonnet').metadata.name,
        imagePullSecrets: [
          { name: 'ghcr-login-secret' },
        ],
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'gateway',
            image: 'ghcr.io/walnuts1018/picca-ai-prototype-gateway:latest',
            imagePullPolicy: 'Always',
            ports: [
              {
                name: 'http',
                containerPort: 8000,
              },
            ],
            env: [
              {
                name: 'QDRANT_URL',
                value: 'http://picca-ai-prototype-qdrant:6333',
              },
              {
                name: 'QDRANT_COLLECTION',
                value: 'picca_images',
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
                value: 'arn:aws:iam::role/picca-ai-prototype-gateway',
              },
              {
                name: 'S3_USE_PATH_STYLE',
                value: 'true',
              },
              {
                name: 'DENSE_SERVICE_URL',
                value: 'http://dense:8001',
              },
              {
                name: 'SPARSE_SERVICE_URL',
                value: 'http://sparse:8002',
              },
              {
                name: 'OCR_SERVICE_URL',
                value: 'http://ocr:8003',
              },
              {
                name: 'CAPTION_SERVICE_URL',
                value: 'http://caption:8004',
              },
              {
                name: 'INGEST_BATCH_SIZE',
                value: '8',
              },
              {
                name: 'INGEST_BATCH_WAIT_SECONDS',
                value: '2.0',
              },
            ],
            resources: {
              requests: {
                cpu: '100m',
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
                name: 'seaweedfs-sts-token',
                mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
                readOnly: true,
              },
            ],
          }, {
            securityContext: {
              allowPrivilegeEscalation: false,
              readOnlyRootFilesystem: false,
            },
          }),
        ],
        volumes: [
          {
            name: 'tmp',
            emptyDir: {},
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
