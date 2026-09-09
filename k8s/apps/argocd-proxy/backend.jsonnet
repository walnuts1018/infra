local app = import 'app.json5';
{
  apiVersion: 'gateway.envoyproxy.io/v1alpha1',
  kind: 'Backend',
  metadata: {
    name: app.name,
    namespace: app.namespace,
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
