local app = import 'app.json5';
local deployment = import 'deployment.jsonnet';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: deployment.metadata.name,
    namespace: app.namespace,
  },
  spec: {
    type: 'ClusterIP',
    selector: deployment.spec.selector.matchLabels,
    ports: [
      {
        name: 'http',
        port: 9000,
        targetPort: deployment.spec.template.spec.containers[0].ports[0].name,
        protocol: 'TCP',
      },
    ],
  },
}
