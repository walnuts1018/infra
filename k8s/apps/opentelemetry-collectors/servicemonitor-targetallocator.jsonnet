{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'otel-targetallocator-self',
    namespace: 'opentelemetry-collector',
  },
  spec: {
    selector: {
      matchLabels: {
        'app.kubernetes.io/name': 'prometheus-targetallocator',
      },
    },
    endpoints: [
      {
        port: 'targetallocation',
        path: '/metrics',
        interval: '30s',
      },
    ],
  },
}
