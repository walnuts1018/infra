{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'local-ca-cert',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    isCA: true,
    commonName: 'operator',
    secretName: 'local-ca-secret',
    duration: '70128h',
    privateKey: {
      algorithm: 'ECDSA',
      size: 256,
    },
    issuerRef: {
      name: (import 'selfsigned.jsonnet').metadata.name,
      kind: 'ClusterIssuer',
      group: 'cert-manager.io',
    },
  },
}
