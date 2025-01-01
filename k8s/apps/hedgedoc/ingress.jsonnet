{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    annotations: {
      'nginx.ingress.kubernetes.io/proxy-body-size': '100M',
    },
  },
  spec: {
    ingressClassName: 'cilium',
    rules: [
      {
        host: 'hedgedoc.walnuts.dev',
        http: {
          paths: [
            {
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: (import 'service.jsonnet').metadata.name,
                  port: {
                    number: 3000,
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
