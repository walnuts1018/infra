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
        host: 'github-readme-stats.walnuts.dev',
        http: {
          paths: [
            {
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: (import 'service.json5').metadata.name,
                  port: {
                    number: 80,
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
