local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'akvorado-console',
    namespace: app.namespace,
    labels: labels('akvorado') + {
      'app.kubernetes.io/component': 'console',
    },
  },
  spec: {
    selector: {
      'app.kubernetes.io/name': 'akvorado',
      'app.kubernetes.io/component': 'console',
    },
    ports: [
      { name: 'http', port: 8080, targetPort: 8080, protocol: 'TCP' },
    ],
  },
}
