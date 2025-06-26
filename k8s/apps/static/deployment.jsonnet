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
        securityContext: {
          fsGroup: 101,
          fsGroupChangePolicy: 'OnRootMismatch',
        },
        containers: [
          std.mergePatch((import '../../components/container.libsonnet') {
            name: 'nginx',
            image: 'nginx:1.28.0',
            ports: [
              {
                containerPort: 8080,
              },
            ],
            livenessProbe: {
              httpGet: {
                path: '/healthz',
                port: 8081,
              },
              failureThreshold: 1,
              initialDelaySeconds: 10,
              periodSeconds: 10,
            },
            volumeMounts: [
              {
                mountPath: '/etc/nginx',
                readOnly: true,
                name: 'nginx-conf',
              },
              {
                mountPath: '/tmp',
                name: 'tmp',
              },
              {
                mountPath: '/var/tmp',
                name: 'tmp',
              },
              {
                mountPath: '/var/log/nginx',
                name: 'log-nginx',
              },
              {
                mountPath: '/var/cache/nginx',
                name: 'cache-nginx',
              },
              {
                mountPath: '/var/run',
                name: 'var-run',
              },
            ],
            resources: {
              limits: {
                memory: '100Mi',
              },
              requests: {
                memory: '10Mi',
              },
            },
          }, {
            securityContext: {
              runAsUser: 101,
            },
          }),
        ],
        volumes: [
          {
            name: 'nginx-conf',
            configMap: {
              name: (import 'configmap.jsonnet').metadata.name,
              items: [
                {
                  key: 'nginx.conf',
                  path: 'nginx.conf',
                },
                {
                  key: 'virtualhost.conf',
                  path: 'virtualhost/virtualhost.conf',
                },
              ],
            },
          },
          {
            name: 'tmp',
            emptyDir: {},
          },
          {
            name: 'log-nginx',
            emptyDir: {},
          },
          {
            name: 'cache-nginx',
            emptyDir: {},
          },
          {
            name: 'var-run',
            emptyDir: {},
          },
        ],
      },
    },
  },
}
