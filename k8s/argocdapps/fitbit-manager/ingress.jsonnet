{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    ingressClassName: 'nginx',
    rules: [
      {
        host: 'fitbit.walnuts.dev',
        http: {
          paths: [
            {
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: (import 'service.jsonnet').metadata.name,
                  port: {
                    number: 8080,
                  },
                },
              },
            },
          ],
        },
      },
    ],
  },
}
