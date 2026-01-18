{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
    },
    template: {
      metadata: {
        labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
      },
      spec: {
        containers: [
          {
            name: 'warrior',
            image: 'atdr.meo.ws/archiveteam/warrior-dockerfile@sha256:e8137b57f9ab9619e750b16afb375c203ec9da37389497790bcba28b1aaeabe3',
            imagePullPolicy: 'IfNotPresent',
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
                cpu: '100m',
                memory: '768Mi',
              },
              requests: {
                cpu: '50m',
                memory: '300Mi',
              },
            },
          },
        ],
        nodeSelector: {
          'kubernetes.io/arch': 'amd64',
        },
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
