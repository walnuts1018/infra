{
  apiVersion: 'networking.k8s.io/v1',
  kind: 'Ingress',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    annotations: {
      'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
    },
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
    tls: [
      {
        hosts: [
          'blog.walnuts.dev',
        ],
        secretName: (import 'app.json5').name + '-tls',
      },
    ],
  },
}
