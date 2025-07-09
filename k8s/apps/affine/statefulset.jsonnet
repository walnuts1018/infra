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
        local env = [
          {
            name: 'AFFINE_SERVER_HOST',
            value: 'affine.walnuts.dev',
          },
          {
            name: 'AFFINE_SERVER_PORT',
            value: std.toString($.spec.template.spec.containers[0].ports[0].containerPort),
          },
          {
            name: 'AFFINE_SERVER_EXTERNAL_URL',
            value: 'https://affine.walnuts.dev',
          },
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
                name: (import 'external-secret.jsonnet').spec.target.name,
                key: 'postgres-url',
              },
            },
          },
          {
            name: 'NODE_ENV',
            value: 'production',
          },
          {
            name: 'DEPLOYMENT_TYPE',
            value: 'selfhosted',
          },
          {
            name: 'MAILER_HOST',
            value: 'smtp.resend.com',
          },
          {
            name: 'DEV_SERVER_URL',
            value: 'https://affine.walnuts.dev',
          },
          {
            name: 'MAILER_PORT',
            value: '587',
          },
          {
            name: 'MAILER_USER',
            value: 'resend',
          },
          {
            name: 'MAILER_PASSWORD',
            valueFrom: {
              secretKeyRef: {
                name: (import 'external-secret.jsonnet').spec.target.name,
                key: 'mailer-password',
              },
            },
          },
          {
            name: 'MAILER_SENDER',
            value: 'affine@resend.walnuts.dev',
          },
          {
            name: 'OAUTH_OIDC_ISSUER',
            value: 'https://auth.walnuts.dev',
          },
          {
            name: 'OAUTH_OIDC_CLIENT_ID',
            value: '296071951179383022',
          },
          {
            name: 'OAUTH_OIDC_CLIENT_SECRET',
            valueFrom: {
              secretKeyRef: {
                name: (import 'external-secret.jsonnet').spec.target.name,
                key: 'oidc-client-secret',
              },
            },
          },
        ],
        local volumeMounts = [
          {
            mountPath: '/root/.affine/storage',
            name: 'affine-storage',
          },
          {
            mountPath: '/root/.affine/config',
            name: 'affine-config',
          },
          {
            mountPath: '/root/.affine/config/affine.js',
            subPath: 'affine.js',
            readOnly: true,
            name: 'affine-config-affine-js',
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
        initContainers: [
          (import '../../components/container.libsonnet') {
            name: 'affine-init',
            image: 'ghcr.io/toeverything/affine-graphql:stable-1623f5d',
            command: ['sh', '-c', 'node ./scripts/self-host-predeploy'],
            securityContext:: null,
            env: env,
            volumeMounts: volumeMounts,
            resources: {
              limits: {
                memory: '512Mi',
              },
              requests: {
                memory: '360Mi',
              },
            },
          },
        ],
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'affine',
            image: 'ghcr.io/toeverything/affine-graphql:stable-1623f5d',
            command: ['sh', '-c', 'node ./dist/index.js'],
            securityContext:: null,
            env: env,
            volumeMounts: volumeMounts,
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
            resources: {
              limits: {
                cpu: '500m',
                memory: '512Mi',
              },
              requests: {
                cpu: '2m',
                memory: '180Mi',
              },
            },
            livenessProbe: {
              httpGet: {
                path: '/info',
                port: 'http',
              },
              failureThreshold: 1,
              initialDelaySeconds: 10,
              periodSeconds: 10,
            },
            readinessProbe: {
              httpGet: {
                path: '/info',
                port: 'http',
              },
            },
          },
        ],
        volumes: [
          {
            name: 'affine-config-affine-js',
            configMap: {
              name: (import 'configmap.jsonnet').metadata.name,
              items: [
                {
                  key: 'affine.js',
                  path: 'affine.js',
                },
              ],
            },
          },
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
