local container = import '../../components/container.libsonnet';
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
    selector: {
      matchLabels: (labels)(app.name),
    },
    strategy: {
      type: 'Recreate',
    },
    template: {
      metadata: {
        labels: (labels)(app.name),
      },
      spec: {
        securityContext: {
          fsGroup: 991,
          fsGroupChangePolicy: 'OnRootMismatch',
        },
        initContainers: [
          (container) {
            name: 'misskey-init',
            image: 'misskey/misskey:2026.6.0',
            imagePullPolicy: 'IfNotPresent',
            command: [
              'pnpm',
              'run',
              'init',
            ],
            volumeMounts: [
              {
                name: 'misskey-files',
                mountPath: '/misskey/files',
              },
              {
                name: 'misskey-config',
                mountPath: '/misskey/.config',
                readOnly: true,
              },
            ],
          } + {
            securityContext+: {
              readOnlyRootFilesystem: false,  // TODO: /misskey/built/.config.jsonを生成するせいで、ReadOnlyRootFilesystemにできない
            },
          },
        ],
        containers: [
          (container) {
            name: 'misskey',
            resizePolicy: [
              {
                resourceName: 'cpu',
                restartPolicy: 'NotRequired',
              },
              {
                resourceName: 'memory',
                restartPolicy: 'RestartContainer',
              },
            ],
            image: 'misskey/misskey:2026.6.0',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            volumeMounts: [
              {
                name: 'misskey-files',
                mountPath: '/misskey/files',
              },
              {
                name: 'misskey-config',
                mountPath: '/misskey/.config',
                readOnly: true,
              },
              {
                name: 'tmp',
                mountPath: '/tmp',
              },
            ],
            env: [
              {
                name: 'POSTGRES_USER',
                value: 'misskey',
              },
              {
                name: 'POSTGRES_DB',
                value: 'misskey',
              },
              {
                name: 'POSTGRES_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: externalSecret.spec.target.name,
                    key: 'dbPassword',
                  },
                },
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/healthz',
                port: 3000,
              },
              initialDelaySeconds: 3,
              periodSeconds: 3,
            },
            startupProbe: {
              httpGet: {
                path: '/healthz',
                port: 3000,
              },
              failureThreshold: 30,
              periodSeconds: 10,
            },
            resources: {
              requests: {
                cpu: '150m',
                memory: '800Mi',
              },
              limits: {
                memory: '2Gi',
              },
            },
          } + {
            securityContext+: {
              readOnlyRootFilesystem: false,
            },
          },
        ],
        volumes: [
          {
            name: 'misskey-config',
            secret: {
              secretName: externalSecret.spec.target.name,
            },
          },
          {
            name: 'tmp',
            emptyDir: {},
          },
          {
            name: 'misskey-files',
            emptyDir: {},
          },
        ],
        tolerations: [
          {
            key: 'node.walnuts.dev/untrusted',
            operator: 'Exists',
          },
        ],
      },
    },
  },
}
