local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (labels)(app.name),
    },
    template: {
      metadata: {
        labels: (labels)(app.name),
      },
      spec: {
        containers: [
          {
            name: 'warrior',
            image: 'atdr.meo.ws/archiveteam/warrior-dockerfile@sha256:d8016cd962ec67736646b6dfe963a4cab215991b1c95b67c85a395502abd7610',
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
