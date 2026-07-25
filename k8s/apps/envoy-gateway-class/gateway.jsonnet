{
  apiVersion: 'gateway.networking.k8s.io/v1',
  kind: 'Gateway',
  metadata: {
    name: 'envoy-gateway',
    namespace: (import 'app.json5').namespace,
    annotations: {
      'external-dns-cloudflare.alpha.kubernetes.io/target': '111.100.165.117',
      'external-dns-local.alpha.kubernetes.io/target': '192.168.12.138',
    },
  },
  spec: {
    gatewayClassName: (import 'gateway-class.jsonnet').metadata.name,
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
              name: (import './certificate.jsonnet').spec.secretName,
              group: '',
            },
          ],
        },
      },
      {
        name: 'smtp',
        protocol: 'TCP',
        port: 25,
        allowedRoutes: {
          namespaces: {
            from: 'All',
          },
        },
      },
      {
        name: 'smtps',
        protocol: 'TCP',
        port: 465,
        allowedRoutes: {
          namespaces: {
            from: 'All',
          },
        },
      },
      {
        name: 'submission',
        protocol: 'TCP',
        port: 587,
        allowedRoutes: {
          namespaces: {
            from: 'All',
          },
        },
      },
      {
        name: 'imaps',
        protocol: 'TCP',
        port: 993,
        allowedRoutes: {
          namespaces: {
            from: 'All',
          },
        },
      },
    ],
  },
}
