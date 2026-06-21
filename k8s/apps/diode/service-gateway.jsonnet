local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';

{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: app.name + '-gateway',
    namespace: app.namespace,
    labels: labels(app.name),
  },
  spec: {
    type: 'ExternalName',
    externalName: 'envoy-envoy-gateway-system-envoy-gateway-dc2b3bc0.envoy-gateway-system.svc.cluster.local',
    ports: [
      {
        name: 'http',
        protocol: 'TCP',
        port: 80,
        targetPort: 80,
      },
    ],
  },
}
