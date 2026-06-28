local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-ingester-h2c',
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    type: 'ClusterIP',
    selector: {
      app: 'diode-ingester',
    },
    ports: [
      {
        name: 'grpc',
        protocol: 'TCP',
        appProtocol: 'kubernetes.io/h2c',
        port: 8081,
        targetPort: 8081,
      },
    ],
  },
}
