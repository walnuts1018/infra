local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-dashboard',
    namespace: app.namespace,
  },
  spec: {
    selector: labels(app.name + '-dashboard'),
    ports: [{
      name: 'http',
      port: 80,
      targetPort: 'http',
      protocol: 'TCP',
    }],
  },
}
