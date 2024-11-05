{
  apiVersion: 'opentelemetry.io/v1beta1',
  kind: 'OpenTelemetryCollector',
  spec: {
    managementState: 'managed',
    serviceAccount: (import '../sa.jsonnet').metadata.name,
  },
}
