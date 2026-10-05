{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: 'otel-vyos-collector',
  },
  automountServiceAccountToken: false,
}
