local labels = import '../../../components/labels.libsonnet';
local app = import '../app.json5';
local service = import './service.jsonnet';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: app.name + '-back',
    namespace: app.namespace,
    labels: (labels)(app.name + '-back'),
  },
  spec: {
    ingressClassName: 'cilium',
    rules: [
      {
        host: 'api-openchokin.walnuts.dev',
        http: {
          paths: [
            {
              path: '/',
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
          ],
        },
      },
    ],
  },
}
