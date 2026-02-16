{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Issuer',
  metadata: {
    name: 'cilium-cluster-mesh',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    ca: {
      secretName: (import 'external-secret-cluster-mesh.jsonnet').spec.target.name,
    },
  },
}
