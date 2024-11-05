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
        imagePullSecrets: [
          {
            name: 'ghcr-login-secret',
          },
        ],
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'oekaki-dengon-game-front',
            image: 'ghcr.io/kmc-jp/oekaki-dengon-game-front:v0.0.0-a6d6d6e7d66e6d0dfafbf416b462be908b208489-87',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            env: [
              {
                name: 'API_URL',
                value: 'http://oekaki-dengon-game-front.oekaki-dengon-game.svc.cluster.local:8080/api',
              },
            ],
            resources: {
              limits: {},
              requests: {
                memory: '160Mi',
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
