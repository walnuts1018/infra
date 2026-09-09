local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-headless',
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    clusterIP: 'None',
    selector: labels(app.name),
    ports: [
      {
        name: 'wireguard',
        port: 51820,
        protocol: 'UDP',
      },
    ],
  },
}
