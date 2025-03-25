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
            name: 'wakatime-to-slack-profile',
            image: 'ghcr.io/walnuts1018/wakatime-to-slack-profile:0.2.3',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 8080,
              },
            ],
            env: [
              {
                name: 'GIN_MODE',
                value: 'release',
              },
              {
                name: 'WAKATIME_APP_ID',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'wakatime-app-id',
                  },
                },
              },
              {
                name: 'WAKATIME_CLIENT_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'wakatime-client-secret',
                  },
                },
              },
              {
                name: 'COOKIE_SECRET',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'cookie-secret',
                  },
                },
              },
              {
                name: 'PSQL_ENDPOINT',
                value: 'postgresql-default.databases.svc.cluster.local',
              },
              {
                name: 'PSQL_PORT',
                value: '5432',
              },
              {
                name: 'PSQL_DATABASE',
                value: 'wakatime_to_slack',
              },
              {
                name: 'PSQL_USER',
                value: 'wakatime',
              },
              {
                name: 'PSQL_PASSWORD',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'postgres-password',
                  },
                },
              },
              {
                name: 'SLACK_ACCESS_TOKEN',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'slack-access-token',
                  },
                },
              },
            ],
            volumeMounts: [
              {
                mountPath: '/app/emoji.json',
                subPath: 'emoji.json',
                readOnly: true,
                name: 'emoji-json',
              },
            ],
            resources: {
              limits: {},
              requests: {
                memory: '5Mi',
              },
            },
          },
        ],
        volumes: [
          {
            name: 'emoji-json',
            configMap: {
              name: (import 'configmap.jsonnet').metadata.name,
              items: [
                {
                  key: 'emoji.json',
                  path: 'emoji.json',
                },
              ],
            },
          },
        ],
        priorityClassName: 'low',
      },
    },
  },
}
