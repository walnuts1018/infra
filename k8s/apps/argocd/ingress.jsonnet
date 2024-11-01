{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: (import 'app.libsonnet').appname,
    labels: (import 'app.libsonnet').labels,
  },
  spec: {
    ingressClassName: 'nginx',
    rules: [
      {
        host: 'argocd.walnuts.dev',
        http: {
          paths: [
            {
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: 'argocd-server',
                  port: {
                    name: 'http',
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
