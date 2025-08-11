{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: (import '../app.json5').frontend.name,
    namespace: (import '../app.json5').namespace,
    labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').frontend.name },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').frontend.name },
    },
    template: {
      metadata: {
        labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').frontend.name },
      },
      spec: {
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'ac-hacking-2024-front',
            securityContext: {
              readOnlyRootFilesystem: true,
            },
            image: 'ghcr.io/walnuts1018/2024-ac-hacking-front:1c4c5593eb14f8656449d2176c177ca20679ef56-11',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            resources: {
              limits: {
                memory: '100Mi',
              },
              requests: {
                cpu: '1m',
                memory: '20Mi',
              },
            },
          },
        ],
        nodeSelector: {
          'kubernetes.io/arch': 'amd64',
        },
      },
    },
  },
}
