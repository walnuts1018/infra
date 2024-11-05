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
            image: 'ghcr.io/kmc-jp/oekaki-dengon-game-front:v0.0.0-033204307091c0be33ba4b31a9b214ceba705270-94',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            env: [
              {
                name: 'API_URL',
                value: 'http://' + (import '../../../utils/get-endpoint-from-service.libsonnet')(import 'service.jsonnet') + ':8080/api',
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
