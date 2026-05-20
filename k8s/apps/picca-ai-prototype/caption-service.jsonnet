{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'caption',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-caption'),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 8004,
        targetPort: 8004,
      },
    ],
    selector: (import '../../components/labels.libsonnet')('picca-ai-prototype-caption'),
    type: 'ClusterIP',
  },
}
