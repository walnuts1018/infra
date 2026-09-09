local app = import 'app.json5';
local service = import 'service.jsonnet';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (import 'components/labels.libsonnet')(app.name),
  },
  spec: {
    ingressClassName: 'cilium',
    rules: [
      {
        host: 'httptest.walnuts.dev',
        http: {
          paths: [
            {
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: service.metadata.name,
                  port: {
                    number: service.spec.ports[0].port,
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
