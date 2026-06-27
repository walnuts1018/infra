local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local deployment = import 'deployment.jsonnet';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
  },
  spec: {
    selector: (labels)(app.name),
    ports: [
      {
        protocol: 'TCP',
        port: 8080,
        targetPort: deployment.spec.template.spec.containers[0].ports[0].containerPort,
      },
    ],
    type: 'ClusterIP',
  },
}
