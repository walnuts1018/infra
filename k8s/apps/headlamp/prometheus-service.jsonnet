local app = import 'app.json5';
local deployment = import 'prometheus-proxy-deployment.jsonnet';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'prometheus-k8s',
    namespace: app.namespace,
    labels: {
      'headlamp-prometheus': 'true',
    },
  },
  spec: {
    ports: [
      {
        name: 'http',
        port: 9090,
        protocol: 'TCP',
        targetPort: 'http',
      },
    ],
    selector: deployment.spec.selector.matchLabels,
  },
}
