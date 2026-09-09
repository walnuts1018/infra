local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'argocd-server-grpc',
    namespace: app.namespace,
  },
  spec: {
    ports: [
      {
        name: 'grpc',
        appProtocol: 'kubernetes.io/h2c',
        port: 80,
        targetPort: 8080,
      },
    ],
    selector: {
      'app.kubernetes.io/instance': app.name,
      'app.kubernetes.io/name': 'argocd-server',
    },
  },
}
