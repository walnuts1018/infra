local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-reconciler-h2c',
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    type: 'ClusterIP',
    selector: {
      app: 'diode-reconciler',
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
