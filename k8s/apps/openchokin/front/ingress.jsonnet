{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: (import '../app.json5').name + '-front',
    namespace: (import '../app.json5').namespace,
    labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-front' },
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
