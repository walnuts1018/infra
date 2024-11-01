{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: (import 'app.libsonnet').appname,
    namespace: (import 'app.libsonnet').namespace,
    labels: (import 'app.libsonnet').labels,
  },
  spec: {
    selector: (import 'app.libsonnet').labels,
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
