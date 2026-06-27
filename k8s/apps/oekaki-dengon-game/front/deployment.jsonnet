local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local service = import '../back/service.jsonnet';
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
        imagePullSecrets: [
          {
            name: 'ghcr-login-secret',
          },
        ],
        containers: [
          (import '../../../components/container.libsonnet') {
            name: 'oekaki-dengon-game-front',
            image: 'ghcr.io/kmc-jp/oekaki-dengon-game-front:v0.0.0-10b57aae4bfe56124907ac1b03bc822a635e173f-95',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 3000,
              },
            ],
            env: [
              {
                name: 'API_URL',
                value: 'http://' + (import '../../../utils/get-endpoint-from-service.libsonnet')(service) + ':8080/api',
              },
            ],
            resources: {
              limits: {},
              requests: {
                memory: '80Mi',
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
