{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    annotations: {
      'nginx.ingress.kubernetes.io/proxy-body-size': '10G',
    },
  },
  spec: {
    ingressClassName: 'cilium',
    rules: [
      {
        host: 'mucaron.walnuts.dev',
        http: {
          paths: [
            {
              path: '/api',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: (import './back/service.jsonnet').metadata.name,
                  port: {
                    number: 8080,
                  },
                },
              },
            },
            {
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: (import './front/service.jsonnet').metadata.name,
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
