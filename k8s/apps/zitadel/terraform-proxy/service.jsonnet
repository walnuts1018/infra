{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import 'app.libsonnet').name,
    namespace: (import 'app.libsonnet').namespace,
    labels: (import '../../../components/labels.libsonnet') + { appname: (import 'app.libsonnet').name },
  },
  spec: {
    selector: (import '../../../components/labels.libsonnet') + { appname: (import 'app.libsonnet').name },
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
