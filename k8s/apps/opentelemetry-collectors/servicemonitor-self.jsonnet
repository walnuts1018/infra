{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'ServiceMonitor',
  metadata: {
    name: 'otel-collector-self',
    namespace: 'opentelemetry-collector',
  },
  spec: {
    selector: {
      matchLabels: {
        'operator.opentelemetry.io/collector-service-type': 'monitoring',
      },
    },
    jobLabel: 'app.kubernetes.io/name',
    endpoints: [
      {
        port: 'monitoring',
        path: '/metrics',
        interval: '30s',
      },
    ],
  },
}
