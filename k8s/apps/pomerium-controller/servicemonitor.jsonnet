local app = import 'app.json5';
local helmname = (import 'helm.jsonnet').spec.source.helm.releaseName;

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (import '../../components/labels.libsonnet')(app.name),
  },
  spec: {
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': 'pomerium',
        role: 'metrics',
      },
    },
    endpoints: [
      {
        port: 'metrics',
        path: '/metrics',
        interval: '15s',
        scheme: 'http',
      },
    ],
  },
}
