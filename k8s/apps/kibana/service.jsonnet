{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 5601,
        targetPort: 5601,
      },
    ],
    selector: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    type: 'ClusterIP',
  },
}
