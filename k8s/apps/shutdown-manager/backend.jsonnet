{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'Backend',
  metadata: {
    name: 'kurumi-api-server',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    endpoints: [
      {
        hostname: '192.168.0.17',
        fqdn: {
          hostname: '192.168.0.17',
          port: 16443,
        },
      },
    ],
  },
}
