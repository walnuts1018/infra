{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'ocr',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-ocr'),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 8003,
        targetPort: 8003,
      },
    ],
    selector: (import '../../components/labels.libsonnet')('picca-ai-prototype-ocr'),
    type: 'ClusterIP',
  },
}
