{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
      },
      spec: {
        serviceAccountName: (import 'sa.jsonnet').metadata.name,
        securityContext: {
          fsGroup: 101,
          fsGroupChangePolicy: 'OnRootMismatch',
        },
        containers: [
          {
            name: 'proxy',
            image: 'ghcr.io/walnuts1018/s3-oauth2-proxy:0.0.54',
            env: [
              {
                name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
                value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317',
              },
              {
                name: 'SESSION_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'session-secret',
                  },
                },
              },
              {
                name: 'OIDC_ISSUER_URL',
                value: 'https://auth.walnuts.dev',
              },
              {
                name: 'OIDC_CLIENT_ID',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'client-id',
                  },
                },
              },
              {
                name: 'OIDC_CLIENT_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'client-secret',
                  },
                },
              },
              {
                name: 'OIDC_REDIRECT_URL',
                value: 'https://ipu.walnuts.dev/auth/callback',
              },
              {
                name: 'OIDC_ALLOWED_GROUPS',
                value: '326185042176901521:viewer',
              },
              {
                name: 'OIDC_GROUP_CLAIM',
                value: 'my:zitadel:grants',
              },
              {
                name: 'S3_BUCKET',
                value: 'ipu',
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
                value: 'https://httptest.local.walnuts.dev',
              },
              {
                name: 'AWS_REGION',
                value: 'us-east-1',
              },
              {
                name: 'AWS_ROLE_ARN',
                value: 'arn:aws:iam::role/ipu',
              },
              {
                name: 'S3_USE_PATH_STYLE',
                value: 'true',
              },
            ],
            ports: [
              {
                name: 'http',
                containerPort: 8080,
                protocol: 'TCP',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/livez',
                port: 'http',
              },
            },
            readinessProbe: {
              httpGet: {
                path: '/readyz',
                port: 'http',
              },
            },
            resources: {
              limits: {
                cpu: '100m',
                memory: '300Mi',
              },
              requests: {
                cpu: '1m',
                memory: '10Mi',
              },
            },
            volumeMounts: [
              {
                name: 'seaweedfs-sts-token',
                mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
                readOnly: true,
              },
            ],
          },
        ],
        volumes: [
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
