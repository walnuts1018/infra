{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: 'otel-prometheus-collector',
  },
  automountServiceAccountToken: false,
}
