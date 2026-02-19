{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'Backend',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    endpoints: [
      {
        ip: {
          address: '192.168.0.14',
          port: 30080,
        },
      },
    ],
  },
}
