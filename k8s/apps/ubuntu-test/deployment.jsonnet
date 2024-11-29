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
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'ubuntu-debug',
            image: 'ghcr.io/cybozu/ubuntu-debug:24.04',
            livenessProbe: {
              httpGet: {
                path: '/healthz',
                port: 8081,
              },
              failureThreshold: 1,
              initialDelaySeconds: 10,
              periodSeconds: 10,
            },
            resources: {
              limits: {
                memory: '100Mi',
              },
              requests: {
                memory: '5Mi',
              },
            },
          }, {
            securityContext:: null,
          }),
        ],
      },
    },
  },
}
