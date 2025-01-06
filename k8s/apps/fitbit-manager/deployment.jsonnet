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
          {
            name: 'fitbit-manager',
            image: 'ghcr.io/walnuts1018/fitbit-manager:1.0.4',
            imagePullPolicy: 'IfNotPresent',
            ports: [
              {
                containerPort: 8080,
              },
            ],
            resources: {
              limits: {
                memory: '300Mi',
              },
              requests: {
                memory: '10Mi',
              },
            },
            env: (import 'env.libsonnet').env,
          },
        ],
      },
    },
  },
}
