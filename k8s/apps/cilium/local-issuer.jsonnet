{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Issuer',
  metadata: {
    name: 'cilium-cluster-mesh',
  },
  spec: {
    ca: {
      secretName: (import 'external-secret-cluster-mesh.jsonnet').spec.target.name,
    },
  },
}
