(import '../../components/external-secret.libsonnet') {
  name: 'terrakube-registry-secrets-overlay',
  namespace: (import 'app.json5').namespace,
  data: [
    {
      secretKey: 'patSecret',
      remoteRef: {
        key: 'terrakube',
        property: 'pat_secret',
      },
    },
    {
      secretKey: 'internalSecret',
      remoteRef: {
        key: 'terrakube',
        property: 'internal_secret',
      },
    },
  ],
  template_data: {
    PatSecret: '{{ .patSecret }}',
    InternalSecret: '{{ .internalSecret }}',
  },
}
