{
  apiVersion: 'opentelemetry.io/v1alpha1',
  kind: 'Instrumentation',
  metadata: {
    name: 'default',
  },
  spec: {
    exporter: {
      endpoint: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4317',
    },
    propagators: [
      'tracecontext',
      'baggage',
    ],
    sampler: {
      type: 'parentbased_traceidratio',
      argument: '1',
    },
    python: {
      env: [
        {
          name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
          value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4318',
        },
      ],
    },
    dotnet: {
      env: [
        {
          name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
          value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4318',
        },
      ],
    },
    go: {
      env: [
        {
          name: 'OTEL_EXPORTER_OTLP_ENDPOINT',
          value: 'http://default-collector.opentelemetry-collector.svc.cluster.local:4318',
        },
      ],
      resourceRequirements: {
        limits: {
          cpu: '500m',
          memory: '512Mi',
        },
        requests: {
          cpu: '50m',
          memory: '32Mi',
        },
      },
    },
  },
}
