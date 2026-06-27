local app = import '../app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: app.name + '-back',
    namespace: app.namespace,
    labels: (import '../../../components/labels.libsonnet')(app.name + '-back'),
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
                  name: (import './service.jsonnet').metadata.name,
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
