local helmname = (import 'helm.jsonnet').spec.source.helm.releaseName;

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'loki',
    namespace: 'loki',
    labels: (import '../../components/labels.libsonnet') + { appname: (import 'app.json5').name },
  },
  spec: {
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': 'loki',
        'app.kubernetes.io/instance': helmname,
      },
      matchExpressions: [
        {
          key: 'prometheus.io/service-monitor',
          operator: 'NotIn',
          values: ['false'],
        },
      ],
    },
    endpoints: [
      {
        port: 'http-metrics',
        path: '/metrics',
        interval: '15s',
        relabelings: [
          {
            sourceLabels: ['job'],
            action: 'replace',
            replacement: 'loki/$1',
            targetLabel: 'job',
          },
          {
            action: 'replace',
            replacement: helmname,
            targetLabel: 'cluster',
          },
        ],
        scheme: 'http',
      },
    ],
  },
}
