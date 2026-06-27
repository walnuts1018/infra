local certificate = import './certificate.jsonnet';
local app = import 'app.json5';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'Gateway',
  metadata: {
    name: 'pomerium-gateway',
    namespace: app.namespace,
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
              name: certificate.spec.secretName,
              group: '',
            },
          ],
        },
      },
    ],
  },
}
