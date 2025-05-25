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
            name: 'watchtower',
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
            preStop: {
              exec: {
                command: [
                  'sh',
                  '-c',
                  'echo "Stopping Watchtower..."; sleep 100;',
                ],
              },
            },
            resources: {
              limits: {
              },
              requests: {
              },
            },
          },
        ],
      },
    },
  },
}
