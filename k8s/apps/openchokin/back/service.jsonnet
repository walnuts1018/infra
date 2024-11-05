{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import '../app.json5').name + '-back',
    namespace: (import '../app.json5').namespace,
    labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-back' },
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 8080,
        targetPort: 8080,
      },
    ],
    selector: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-back' },
    type: 'ClusterIP',
  },
}
