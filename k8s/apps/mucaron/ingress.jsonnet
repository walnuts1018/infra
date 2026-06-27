local service = import './back/service.jsonnet';
local app = import 'app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
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
                  name: service.metadata.name,
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
