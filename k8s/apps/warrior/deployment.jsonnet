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
          {
            name: 'warrior',
            image: 'atdr.meo.ws/archiveteam/warrior-dockerfile:latest',
            ports: [
              {
                containerPort: 8001,
                name: 'http',
              },
            ],
            env: [
              {
                name: 'DOWNLOADER',
                value: 'walnuts1018',
              },
              {
                name: 'SELECTED_PROJECT',
                value: 'auto',
              },
              {
                name: 'CONCURRENT_ITEMS',
                value: '6',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/info',
                port: 8001,
              },
              failureThreshold: 1,
              initialDelaySeconds: 10,
              periodSeconds: 10,
            },
            lifecycle: {
              preStop: {
                exec: {
                  command: [
                    'sh',
                    '-c',
                    'echo "Stopping Warrior..."; sleep 100;',
                  ],
                },
              },
            },
            resources: {
              limits: {
                cpu: '1',
                memory: '1Gi',
              },
              requests: {
                cpu: '20m',
                memory: '175Mi',
              },
            },
          },
        ],
        nodeSelector: {
          'kubernetes.io/arch': 'amd64',
        },
      },
    },
  },
}
