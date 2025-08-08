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
          fsGroup: 1000,
          fsGroupChangePolicy: 'OnRootMismatch',
        },
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'n8n',
            image: 'n8nio/n8n:1.106.2',
            command: ['/bin/sh'],
            args: ['-c', 'n8n start'],
            ports: [
              {
                containerPort: 5678,
              },
            ],
            env: [
              {
                name: 'DB_TYPE',
                value: 'postgresdb',
              },
              {
                name: 'DB_POSTGRESDB_HOST',
                value: 'postgresql-default.databases.svc.cluster.local',
              },
              {
                name: 'DB_POSTGRESDB_PORT',
                value: '5432',
              },
              {
                name: 'DB_POSTGRESDB_DATABASE',
                value: 'n8n',
              },
              {
                name: 'DB_POSTGRESDB_USER',
                value: 'n8n',
              },
              {
                name: 'DB_POSTGRESDB_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'postgres-password',
                  },
                },
              },
              {
                name: 'N8N_PROTOCOL',
                value: 'http',
              },
              {
                name: 'N8N_PORT',
                value: '5678',
              },
            ],
            resources: {
              requests: {
                memory: '250Mi',
              },
              limits: {
                memory: '500Mi',
              },
            },
            volumeMounts: [
              {
                mountPath: '/home/node/.n8n',
                name: 'data',
              },
              {
                mountPath: '/home/node/.cache',
                name: 'cache',
              },
            ],
          }, {
          }),
        ],
        volumes: [
          {
            name: 'data',
            persistentVolumeClaim: {
              claimName: (import 'pvc.jsonnet').metadata.name,
            },
          },
          {
            name: 'cache',
            emptyDir: {},
          },
        ],
      },
    },
  },
}
