{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import 'app.json5').appname.frontend,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').appname.frontend),
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 3000,
        targetPort: 3000,
      },
    ],
    selector: (import '../../components/labels.libsonnet')((import 'app.json5').appname.frontend),
    type: 'ClusterIP',
  },
}
