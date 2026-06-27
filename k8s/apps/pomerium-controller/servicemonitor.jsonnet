local labels = import '../../components/labels.libsonnet';
local app = import 'app.json5';
local helm = import 'helm.jsonnet';
local helmname = helm.spec.source.helm.releaseName;

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: app.name,
    namespace: app.namespace,
    labels: (labels)(app.name),
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
