{
  apiVersion: 'opentelemetry.io/v1beta1',
  kind: 'OpenTelemetryCollector',
  metadata: {
    name: error 'metadata.name is required',
  },
  spec: {
    managementState: 'managed',
    serviceAccount: (import '../sa.jsonnet').metadata.name,
  },
}
