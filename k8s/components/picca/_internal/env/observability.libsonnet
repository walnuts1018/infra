function(app) [
  {
    name: 'ENVIRONMENT',
    value: 'production',
  },
  {
    name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
    value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4318',
  },
  {
    name: 'LOG_LEVEL',
    value: 'debug',
  },
]
