{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import 'app.json5').appname.backend,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').appname.backend),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 8080,
        targetPort: 8080,
      },
    ],
    selector: (import '../../components/labels.libsonnet')((import 'app.json5').appname.backend),
    type: 'ClusterIP',
  },
}
