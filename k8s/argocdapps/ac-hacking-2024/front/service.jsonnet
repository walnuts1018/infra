{
  kind: 'Service',
  apiVersion: 'v1',
  metadata: {
    name: (import '../app.json5').frontend.name,
    namespace: (import '../app.json5').namespace,
    labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').frontend.name },
  },
  spec: {
    selector: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').frontend.name },
    ports: [
      {
        protocol: 'TCP',
        port: 3000,
        targetPort: (import 'deployment.jsonnet').spec.template.spec.containers[0].ports[0].containerPort,
      },
    ],
    type: 'ClusterIP',
  },
}
