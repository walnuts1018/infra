{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'gateway',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-gateway'),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 8000,
        targetPort: 8000,
      },
    ],
    selector: (import '../../components/labels.libsonnet')('picca-ai-prototype-gateway'),
    type: 'ClusterIP',
  },
}
