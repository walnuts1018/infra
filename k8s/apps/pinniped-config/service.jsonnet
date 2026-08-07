local app = import '../pinniped/app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-supervisor',
    namespace: app.namespace,
  },
  spec: {
    selector: {
      'deployment.pinniped.dev': 'supervisor',
    },
    ports: [
      {
        name: 'https',
        appProtocol: 'https',
        port: 443,
        targetPort: 8443,
      },
    ],
  },
}
