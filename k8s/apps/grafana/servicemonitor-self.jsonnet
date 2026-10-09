{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'grafana-alerting-self',
    namespace: 'monitoring',
  },
  spec: {
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': 'grafana',
        'app.kubernetes.io/instance': 'grafana',
      },
    },
    endpoints: [
      {
        port: 'service',
        path: '/metrics',
        interval: '30s',
      },
    ],
  },
}
