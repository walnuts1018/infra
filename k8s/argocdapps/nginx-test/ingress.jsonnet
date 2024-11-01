{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: (import 'app.json5').name
    namespace: (import 'app.json5').namespace,
    labels: (import '../../common/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    ingressClassName: 'nginx',
    rules: [
      {
        host: 'nginxtest.walnuts.dev',
        http: {
          paths: [
            {
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: (import 'service.jsonnet').metadata.name,
                  port: {
                    number: (import 'service.jsonnet').spec.ports[0].port,
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
