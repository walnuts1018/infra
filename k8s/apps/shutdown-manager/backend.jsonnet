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
        fqdn: {
          hostname: 'kurumi.local.walnuts.dev',
          port: 443,
        },
      },
    ],
  },
}
