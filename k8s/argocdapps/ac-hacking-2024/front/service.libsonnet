{
  kind: 'Service',
  apiVersion: 'v1',
  metadata: {
    name: (import '../app.json5').frontend.name,
    namespace: (import '../app.json5').namespace,
    labels: (import '../../../common/labels.libsonnet') + { appname: (import '../app.json5').frontend.name },
  },
  spec: {
    selector: (import '../../../common/labels.libsonnet') + { appname: (import '../app.json5').frontend.name },
    ports: [
      {
        protocol: 'TCP',
        port: 3000,
        targetPort: (import 'deployment.libsonnet').spec.template.spec.containers[0].ports[0].containerPort,
      },
    ],
    type: 'ClusterIP',
  },
}
