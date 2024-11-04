{
  kind: 'Service',
  apiVersion: 'v1',
  metadata: {
    name: (import '../app.json5').name + '-back',
    namespace: (import '../app.json5').namespace,
    labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name },
  },
  spec: {
    selector: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').name },
    ports: [
      {
        protocol: 'TCP',
        port: 8080,
        targetPort: 8080,
      },
    ],
    type: 'ClusterIP',
  },
}
