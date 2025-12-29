{
  apiVersion: 'gateway.networking.k8s.io/v1alpha3',
  kind: 'BackendTLSPolicy',
  metadata: {
    name: 'kurumi-api-server',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    targetRefs: [
      {
        group: 'gateway.envoyproxy.io',
        kind: 'Backend',
        name: (import 'backend.jsonnet').metadata.name,
        sectionName: '443',
      },
    ],
    validation: {
      wellKnownCACertificates: 'System',
      hostname: 'kurumi.local.walnuts.dev',
    },
  },
}
