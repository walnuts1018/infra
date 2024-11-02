{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    endpoints: [
      {
        honorLabels: false,
        honorTimestamps: true,
        path: '/metrics',
        targetPort: 60123,
      },
    ],
    jobLabel: 'cloudflared',
    namespaceSelector: {
      matchNames: [
        (import 'app.json5').namespace,
      ],
    },
    selector: {
      matchLabels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
    },
  },
}
