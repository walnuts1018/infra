{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'seaweedfs-tikv-client',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    secretName: 'seaweedfs-tikv-client',
    duration: '8760h',
    renewBefore: '360h',
    commonName: 'SeaweedFS',
    usages: [
      'client auth',
    ],
    issuerRef: {
      name: 'local',
      kind: 'ClusterIssuer',
      group: 'cert-manager.io',
    },
  },
}
