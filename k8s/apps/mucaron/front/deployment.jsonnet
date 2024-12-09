{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import '../app.json5').name + '-front',
    namespace: (import '../app.json5').namespace,
    labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-front' },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-front' },
    },
    template: {
      metadata: {
        labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-front' },
      },
      spec: {
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'mucaron-front',
            image: 'ghcr.io/walnuts1018/mucaron-frontend:c50e0d09f307d7b9cd04d9edf59a632e6a321b01-62',
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
                memory: '20Mi',
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
