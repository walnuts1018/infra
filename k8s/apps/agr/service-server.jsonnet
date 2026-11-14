local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-server',
    namespace: app.namespace,
    labels: labels(app.name + '-server'),
  },
  spec: {
    type: 'ClusterIP',
    selector: labels(app.name + '-server'),
    ports: [
      { name: 'grpc-web', port: 8080, targetPort: 8080, protocol: 'TCP' },
      { name: 'health', port: 8081, targetPort: 8081, protocol: 'TCP' },
    ],
  },
}
