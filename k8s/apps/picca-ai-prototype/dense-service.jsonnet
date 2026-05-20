{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'dense',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-dense'),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 8001,
        targetPort: 8001,
      },
    ],
    selector: (import '../../components/labels.libsonnet')('picca-ai-prototype-dense'),
    type: 'ClusterIP',
  },
}
