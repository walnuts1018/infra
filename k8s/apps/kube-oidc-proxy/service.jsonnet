local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name,
    namespace: app.namespace,
  },
  spec: {
    ports: [
      {
        name: 'https',
        port: 443,
        protocol: 'TCP',
        targetPort: 'https',
      },
    ],
    selector: {
      'app.kubernetes.io/name': app.name,
    },
    type: 'ClusterIP',
  },
}
