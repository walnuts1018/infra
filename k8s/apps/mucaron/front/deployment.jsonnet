local container = import '../../../components/container.libsonnet';
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
    replicas: 1,
    selector: {
      matchLabels: (labels)(app.name + '-front'),
    },
    template: {
      metadata: {
        labels: (labels)(app.name + '-front'),
      },
      spec: {
        containers: [
          (container) {
            name: 'mucaron-front',
            image: 'ghcr.io/walnuts1018/mucaron-frontend:6815d5031e94f24ff1027f8616f7a8315a082f66-64',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            resources: {
              limits: {
                cpu: '500m',
                memory: '512Mi',
              },
              requests: {
                cpu: '10m',
                memory: '100Mi',
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
