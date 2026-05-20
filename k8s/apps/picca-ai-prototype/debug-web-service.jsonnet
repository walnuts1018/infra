{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'debug-web',
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')('picca-ai-prototype-debug-web'),
  },
  spec: {
    selector: (import '../../components/labels.libsonnet')('picca-ai-prototype-debug-web'),
    ports: [
      {
        name: 'http',
        protocol: 'TCP',
        port: 8080,
        targetPort: 'http',
      },
    ],
    type: 'ClusterIP',
  },
}
