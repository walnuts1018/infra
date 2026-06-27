local certificate = import './certificate.jsonnet';
local app = import 'app.json5';
local gatewayClass = import 'gateway-class.jsonnet';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'Gateway',
  metadata: {
    name: 'envoy-gateway',
    namespace: app.namespace,
    annotations: {
      'external-dns-cloudflare.alpha.kubernetes.io/target': '111.100.165.117',
      'external-dns-local.alpha.kubernetes.io/target': '192.168.0.138',
    },
  },
  spec: {
    gatewayClassName: gatewayClass.metadata.name,
    listeners: [
      {
        name: 'http',
        protocol: 'HTTP',
        port: 80,
        allowedRoutes: {
          namespaces: {
            from: 'All',
          },
        },
      },
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
