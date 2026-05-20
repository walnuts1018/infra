{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'sparse',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-sparse'),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 8002,
        targetPort: 8002,
      },
    ],
    selector: (import '../../components/labels.libsonnet')('picca-ai-prototype-sparse'),
    type: 'ClusterIP',
  },
}
