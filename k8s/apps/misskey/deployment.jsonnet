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
    strategy: {
      type: 'Recreate',
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
      },
      spec: {
        securityContext: {
          fsGroup: 991,
          fsGroupChangePolicy: 'OnRootMismatch',
        },
        initContainers: [
          (import '../../components/container.libsonnet') {
            name: 'misskey-init',
            image: 'misskey/misskey:2024.11.0',
            imagePullPolicy: 'IfNotPresent',
            command: [
              'pnpm',
              'run',
              'init',
            ],
            volumeMounts: [
              {
                name: 'misskey-pv',
                mountPath: '/misskey/files',
              },
              {
                name: 'misskey-config',
                mountPath: '/misskey/.config',
                readOnly: true,
              },
            ],
          },
        ],
        containers: [
          (import '../../components/container.libsonnet') {
            name: 'misskey',
            image: 'misskey/misskey:2024.11.0',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            volumeMounts: [
              {
                name: 'misskey-pv',
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
                    name: (import 'external-secret.jsonnet').metadata.name,
                    key: 'misskeydbpassword',
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
                memory: '512Mi',
              },
              limits: {},
            },
          },
        ],
        volumes: [
          {
            name: 'misskey-pv',
            persistentVolumeClaim: {
              claimName: (import 'pvc.jsonnet').metadata.name,
            },
          },
          {
            name: 'misskey-config',
            secret: {
              secretName: (import 'external-secret.jsonnet').metadata.name,
            },
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
