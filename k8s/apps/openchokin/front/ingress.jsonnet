local app = import '../app.json5';
{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: app.name + '-front',
    namespace: app.namespace,
    labels: (import '../../../components/labels.libsonnet')(app.name + '-front'),
  },
  spec: {
    ingressClassName: 'cilium',
    rules: [
      {
        host: 'openchokin.walnuts.dev',
        http: {
          paths: [
            {
              path: '/',
              pathType: 'Prefix',
              backend: {
                service: {
                  name: (import './service.jsonnet').metadata.name,
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
