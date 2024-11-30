{
  apiVersion: 'apps/v1',
  kind: 'StatefulSet',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    selector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
    serviceName: (import 'service.jsonnet').metadata.name,
    replicas: 1,
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
      },
      spec: {
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'affine',
            image: 'ghcr.io/toeverything/affine-graphql:stable-1623f5d',
            command: ['sh', '-c', 'node ./scripts/self-host-predeploy && node ./dist/index.js'],
            securityContext:: null,
            env: [
              {
                name: 'AFFINE_SERVER_HOST',
                value: 'affine.walnuts.dev',
              },
              {
                name: 'AFFINE_SERVER_PORT',
                value: $.spec.template.spec.containers[0].ports[0].containerPort,
              },
              {
                name: 'AFFINE_SERVER_EXTERNAL_URL',
                value: 'https://affine.walnuts.dev',
              }
              {
                name: 'NODE_OPTIONS',
                value: '--import=./scripts/register.js',
              },
              {
                name: 'AFFINE_CONFIG_PATH',
                value: $.spec.template.spec.containers[0].volumeMounts[1].mountPath,
              },
              {
                name: 'REDIS_SERVER_HOST',
                value: (import 'redis.jsonnet').metadata.name,
              },
              {
                name: 'DATABASE_URL',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').metadata.name,
                    key: 'postgres-url',
                  },
                },
              },
              {
                name: 'NODE_ENV',
                value: 'production',
              },
              {
                name: 'MAILER_HOST',
                value: 'smtp.resend.com',
              },
              {
                name: 'MAILER_PORT',
                value: '587',
              },
              {
                name: 'MAILER_USER',
                value: 'affine@resend.walnuts.dev',
              },
              {
                name: 'MAILER_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').metadata.name,
                    key: 'mailer-password',
                  },
                },
              },
            ],
            ports: [
              {
                containerPort: 3010,
                name: 'http',
              },
              {
                containerPort: 5555,
                name: 'prisma',
              },
            ],
            volumeMounts: [
              {
                mountPath: '/root/.affine/storage',
                name: 'affine-storage',
              },
              {
                mountPath: '/root/.affine/config',
                name: 'affine-config',
              },
              {
                mountPath: '/usr/local/share/.cache',
                name: 'usr-local-share-cache',
              },
              {
                mountPath: '/tmp',
                name: 'tmp',
              },
            ],
          },
        ],
        volumes: [
          {
            name: 'affine-storage',
            persistentVolumeClaim: {
              claimName: (import 'pvc.jsonnet').metadata.name,
            },
          },
          {
            name: 'affine-config',
            emptyDir: {},
          },
          {
            name: 'usr-local-share-cache',
            emptyDir: {},
          },
          {
            name: 'tmp',
            emptyDir: {},
          },
        ],
      },
    },
  },
}
