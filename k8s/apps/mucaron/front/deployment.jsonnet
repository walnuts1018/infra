local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: app.name + '-front',
    namespace: app.namespace,
    labels: (labels)(app.name + '-front'),
  },
  spec: {
    selector: {
      matchLabels: (labels)(app.name + '-front'),
    },
    template: {
      metadata: {
        labels: (labels)(app.name + '-front'),
      },
      spec: {
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'mucaron-front',
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
            image: 'ghcr.io/walnuts1018/mucaron-frontend:6815d5031e94f24ff1027f8616f7a8315a082f66-64',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            resources: {
              requests: {
                cpu: '1m',
                memory: '95Mi',
              },
              limits: {
                cpu: '500m',
                memory: '512Mi',
              },
            },
            volumeMounts: [
              {
                name: 'next-cache',
                mountPath: '/app/.next/cache',
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/healthz',
                port: 3000,
              },
            },
            readinessProbe: {
              httpGet: {
                path: '/healthz',
                port: 3000,
              },
            },
          },
        ],
        volumes: [
          {
            name: 'next-cache',
            emptyDir: {},
          },
        ],
      },
    },
  },
}
