{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import '../app.json5').name + '-front',
    namespace: (import '../app.json5').namespace,
    labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-front' },
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 3000,
        targetPort: 3000,
      },
    ],
    selector: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name + '-front' },
    type: 'ClusterIP',
  },
}
