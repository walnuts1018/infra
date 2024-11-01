{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import '../app.json5').backend.name,
    labels: (import '../../../common/labels.libsonnet') + { appname: (import '../app.json5').backend.name },
  },
  spec: {
    selector: (import '../../../common/labels.libsonnet') + { appname: (import '../app.json5').backend.name },
    ports: [
      {
        protocol: 'TCP',
        port: 8080,
        targetPort: (import 'deployment.jsonnet').spec.template.spec.containers[0].ports[0].containerPort,
      },
    ],
    type: 'ClusterIP',
  },
}
