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
            image: 'ghcr.io/toeverything/affine-graphql:stable',
            command: ['sh', '-c', 'node ./scripts/self-host-predeploy && node ./dist/index.js'],
            env: [
              {
                name: 'AFFINE_SERVER_HOST',
                value: 'affine.walnuts.dev',
              },
              {
                name: 'AFFINE_SERVER_PORT',
                value: '443',
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
                value: '/root/.affine/config',
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
        ],
      },
    },
  },
}
