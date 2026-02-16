{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 80,
        protocol: 'TCP',
        targetPort: 'http',
      },
    ],
    selector: (import '../../components/labels.libsonnet')((import 'app.json5').name),
    type: 'ClusterIP',
  },
}
