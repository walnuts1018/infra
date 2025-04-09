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
          (import '../../components/container.libsonnet') {
            name: 'hedgedoc',
            image: 'quay.io/hedgedoc/hedgedoc:1.10.3',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            securityContext:: null,
            resources: {
              limits: {},
              requests: {
                memory: '80Mi',
              },
            },
            env: [
              {
                name: 'CMD_LOGLEVEL',
                value: 'debug',
              },
              {
                name: 'CMD_USECDN',
                value: 'false',
              },
              {
                name: 'CMD_DB_URL',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'db-url',
                  },
                },
              },
              {
                name: 'CMD_DOMAIN',
                value: 'hedgedoc.walnuts.dev',
              },
              {
                name: 'CMD_OAUTH2_USER_PROFILE_URL',
                value: 'https://auth.walnuts.dev/oidc/v1/userinfo',
              },
              {
                name: 'CMD_OAUTH2_USER_PROFILE_USERNAME_ATTR',
                value: 'preferred_username',
              },
              {
                name: 'CMD_OAUTH2_USER_PROFILE_DISPLAY_NAME_ATTR',
                value: 'name',
              },
              {
                name: 'CMD_OAUTH2_USER_PROFILE_EMAIL_ATTR',
                value: 'email',
              },
              {
                name: 'CMD_OAUTH2_TOKEN_URL',
                value: 'https://auth.walnuts.dev/oauth/v2/token',
              },
              {
                name: 'CMD_OAUTH2_AUTHORIZATION_URL',
                value: 'https://auth.walnuts.dev/oauth/v2/authorize',
              },
              {
                name: 'CMD_OAUTH2_CLIENT_ID',
                value: '242480725109048091@walnuts.dev',
              },
              {
                name: 'CMD_OAUTH2_CLIENT_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'client-secret',
                  },
                },
              },
              {
                name: 'CMD_OAUTH2_PROVIDERNAME',
                value: 'walnuts.dev',
              },
              {
                name: 'CMD_OAUTH2_SCOPE',
                value: 'openid profile email',
              },
              {
                name: 'CMD_PROTOCOL_USESSL',
                value: 'true',
              },
              {
                name: 'CMD_EMAIL',
                value: 'false',
              },
              {
                name: 'CMD_OAUTH2_ROLES_CLAIM',
                value: 'my:zitadel:grants',
              },
              {
                name: 'CMD_OAUTH2_ACCESS_ROLE',
                value: '237477822715658605:hedgedoc-user',
              },
              {
                name: 'CMD_IMAGE_UPLOAD_TYPE',
                value: 'minio',
              },
              {
                name: 'CMD_MINIO_ACCESS_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'minio-access-key',
                  },
                },
              },
              {
                name: 'CMD_MINIO_SECRET_KEY',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'minio-secret-key',
                  },
                },
              },
              {
                name: 'CMD_MINIO_ENDPOINT',
                value: 'minio.minio.svc.cluster.local',
              },
              {
                name: 'CMD_MINIO_PORT',
                value: '9000',
              },
              {
                name: 'CMD_MINIO_SECURE',
                value: 'false',
              },
              {
                name: 'CMD_S3_BUCKET',
                value: 'hedgedoc',
              },
              {
                name: 'CMD_DEFAULT_PERMISSION',
                value: 'limited',
              },
              {
                name: 'CMD_SESSION_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'session-secret',
                  },
                },
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/_health',
                port: 3000,
              },
              initialDelaySeconds: 3,
              periodSeconds: 3,
            },
            startupProbe: {
              httpGet: {
                path: '/_health',
                port: 3000,
              },
              failureThreshold: 30,
              periodSeconds: 10,
            },
          },
        ],
      },
    },
  },
}
