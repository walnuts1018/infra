{
  apiVersion: 'cert-manager.io/v1',
  kind: 'ClusterIssuer',
  metadata: {
    name: 'local',
  },
  spec: {
    ca: {
      secretName: (import 'local-cert.jsonnet').spec.secretName,
    },
  },
}
