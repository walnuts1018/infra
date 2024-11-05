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
            name: 'github-readme-stats',
            image: 'ghcr.io/walnuts1018/github-readme-stats:v1.0.3',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 80,
              },
            ],
            resources: {
              limits: {},
              requests: {
                memory: '32Mi',
              },
            },
            env: [
              {
                name: 'PAT_1',
                valueFrom: {
                  secretKeyRef: {
                    name: (import 'external-secret.jsonnet').spec.target.name,
                    key: 'github-token',
                  },
                },
              },
            ],
          },
        ],
      },
    },
  },
}
