local app = import 'app.json5';
local certificate = import 'certificate.jsonnet';
{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'Gateway',
  metadata: {
    name: 'cilium-gateway',
    namespace: app.namespace,
  },
  spec: {
    gatewayClassName: (import 'gateway-class.jsonnet').metadata.name,
    addresses: [
      {
        type: 'IPAddress',
        value: '192.168.16.159',
      },
    ],
    listeners: [
      {
        name: 'https',
        protocol: 'HTTPS',
        port: 443,
        hostname: 'seaweedfs-biscuit.local.walnuts.dev',
        allowedRoutes: {
          namespaces: {
            from: 'All',
          },
        },
        tls: {
          mode: 'Terminate',
          certificateRefs: [
            {
              name: certificate.spec.secretName,
              kind: 'Secret',
              group: '',
            },
          ],
        },
      },
    ],
  },
}
