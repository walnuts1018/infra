{
  apiVersion: 'opentelemetry.io/v1beta1',
  kind: 'OpenTelemetryCollector',
  spec: {
    managementState: 'managed',
    serviceAccount: (import '../sa.jsonnet').metadata.name,
    config: {
      service: {
        telemetry: {
          metrics: {
            readers: [
              {
                periodic: {
                  interval: 10000,
                  exporter: {
                    otlp: {
                      protocol: 'grpc/protobuf',
                      endpoint: 'http://localhost:14317',
                    },
                  },
                },
              },
            ],
          },
          traces: {
            processors: [
              {
                batch: {
                  exporter: {
                    otlp: {
                      protocol: 'grpc/protobuf',
                      endpoint: 'http://localhost:14317',
                    },
                  },
                },
              },
            ],
          },
          logs: {
            processors: [
              {
                batch: {
                  exporter: {
                    otlp: {
                      protocol: 'grpc/protobuf',
                      endpoint: 'http://localhost:14317',
                    },
                  },
                },
              },
            ],
          },
        },
      },
    },
  },
}
