{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: (import 'app.libsonnet').appname,
    namespace: (import 'app.libsonnet').namespace,
    labels: (import 'app.libsonnet').labels,
  },
  spec: {
    ingressClassName: 'nginx',
    rules: [
      {
        host: 'blog.walnuts.dev',
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