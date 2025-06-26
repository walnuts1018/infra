{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: (import 'app.json5').name + '-sts-cert',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    dnsNames: [
      'sts',
      'sts.minio-operator.svc',
      'sts.minio-operator.svc.cluster.local',
    ],
    secretName: 'sts-tls',
    issuerRef: {
      name: (import 'ca-issuer.jsonnet').metadata.name,
    },
  },
}
