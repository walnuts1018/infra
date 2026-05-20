{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'qdrant',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-qdrant'),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 6333,
        targetPort: 6333,
      },
      {
        name: 'grpc',
        port: 6334,
        targetPort: 6334,
      },
    ],
    selector: (import '../../components/labels.libsonnet')('picca-ai-prototype-qdrant'),
    type: 'ClusterIP',
  },
}
