{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    dnsNames: [
      'minio-biscuit.local.walnuts.dev',
      'minio-biscuit-console.local.walnuts.dev',
      'minio.minio-biscuit.svc.cluster.local',
      '*.minio.minio-biscuit.svc.cluster.local',
      'minio.minio-biscuit.svc.clusterset.local',
      '*.minio.minio-biscuit.svc.clusterset.local',
    ],
    secretName: $.metadata.name + '-tls',
    issuerRef: {
      kind: 'ClusterIssuer',
      name: (import '../clusterissuer/local-issuer.jsonnet').metadata.name,
    },
  },
}
