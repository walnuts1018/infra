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
            name: 'nginx-test',
            image: 'nginx:1.27.2',
            ports: [
              {
                containerPort: 8080,
              },
            ],
            securityContext: {},
            volumeMounts: [
              {
                mountPath: '/etc/nginx',
                readOnly: true,
                name: 'nginx-test-conf',
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
                memory: '5Mi',
              },
            },
          },
        ],
        volumes: [
          {
            name: 'nginx-test-conf',
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
