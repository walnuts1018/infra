local helmname = (import 'helm.jsonnet').spec.source.helm.releaseName;

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
    labels: (import '../../components/labels.libsonnet')((import 'app.json5').name),
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
