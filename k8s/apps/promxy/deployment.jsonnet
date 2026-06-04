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
          (import '../../components/container.libsonnet') {
            name: 'promxy',
            image: 'quay.io/jacksontj/promxy:v0.0.93',
            args: [
              '--config=/etc/promxy/config.yaml',
            ],
            ports: [
              {
                name: 'http',
                containerPort: 8082,
              },
            ],
            volumeMounts: [
              {
                name: 'config',
                mountPath: '/etc/promxy',
                readOnly: true,
              },
            ],
            resources: {
              requests: {
                cpu: '50m',
                memory: '128Mi',
              },
              limits: {
                cpu: '1',
                memory: '512Mi',
              },
            },
          },
        ],
        volumes: [
          {
            name: 'config',
            configMap: {
              name: (import 'configmap.jsonnet').metadata.name,
            },
          },
        ],
      },
    },
  },
}
