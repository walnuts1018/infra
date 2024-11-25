{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    selector: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
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
