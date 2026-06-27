local app = import 'app.json5';
local selfsigned = import 'selfsigned.jsonnet';
{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'local-ca-cert',
    namespace: app.namespace,
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
      name: selfsigned.metadata.name,
      kind: 'ClusterIssuer',
      group: 'cert-manager.io',
    },
  },
}
