{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: (import 'app.json5').name + '-ca-certificate',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    isCA: true,
    commonName: 'operator',
    secretName: (import 'app.json5').caSecretName,
    duration: '70128h',
    privateKey: {
      algorithm: 'ECDSA',
      size: 256,
    },
    issuerRef: {
      name: 'selfsigned',
      kind: 'ClusterIssuer',
      group: 'cert-manager.io',
    },
  },
}
