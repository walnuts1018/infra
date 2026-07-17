local app = import 'app.json5';
local labels = import '../../components/labels.libsonnet';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'akvorado-orchestrator',
    namespace: app.namespace,
    labels: labels('akvorado') + {
      'app.kubernetes.io/component': 'orchestrator',
    },
  },
  spec: {
    publishNotReadyAddresses: true,
    selector: {
      'app.kubernetes.io/name': 'akvorado',
      'app.kubernetes.io/component': 'orchestrator',
    },
    ports: [
      { name: 'http', port: 8080, targetPort: 8080, protocol: 'TCP' },
    ],
  },
}
