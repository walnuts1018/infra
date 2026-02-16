{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'Gateway',
  metadata: {
    name: 'pomerium-gateway',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    gatewayClassName: 'pomerium-gateway',
    listeners: [
      {
        name: 'https',
        protocol: 'HTTPS',
        port: 443,
        allowedRoutes: {
          namespaces: {
            from: 'All',
          },
        },
        tls: {
          mode: 'Terminate',
          certificateRefs: [
            {
              kind: 'Secret',
              name: (import './certificate.jsonnet').spec.secretName,
              group: '',
            },
          ],
        },
      },
    ],
  },
}
