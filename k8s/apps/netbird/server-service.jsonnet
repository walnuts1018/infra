local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-server',
    namespace: app.namespace,
  },
  spec: {
    selector: labels(app.name + '-server'),
    ports: [
      {
        name: 'http',
        port: 80,
        targetPort: 'http',
        protocol: 'TCP',
      },
      {
        name: 'grpc',
        port: 81,
        targetPort: 'http',
        protocol: 'TCP',
        appProtocol: 'kubernetes.io/h2c',
      },
      {
        name: 'metrics',
        port: 9090,
        targetPort: 'metrics',
        protocol: 'TCP',
      },
    ],
  },
}
