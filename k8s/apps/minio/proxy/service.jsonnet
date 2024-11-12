{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import '../app.json5').proxy.name,
    namespace: (import '../app.json5').namespace,
    labels: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').proxy.name },
  },
  spec: {
    selector: (import '../../../components/labels.libsonnet') + { appname: (import '../app.json5').proxy.name },
    ports: [
      {
        name: 'minio',
        protocol: 'TCP',
        port: 9000,
        targetPort: (import 'deployment.jsonnet').spec.template.spec.containers[0].ports[0].containerPort,
      },
      {
        name: 'minio-console',
        protocol: 'TCP',
        port: 9001,
        targetPort: (import 'deployment.jsonnet').spec.template.spec.containers[0].ports[1].containerPort,
      },
    ],
    type: 'ClusterIP',
  },
}
