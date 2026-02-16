{
  apiVersion: 'gateway.networking.k8s.io/v1beta1',
  kind: 'ReferenceGrant',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import '../seaweedfs-default/app.json5').namespace,
  },
  spec: {
    from: [
      {
        group: 'gateway.networking.k8s.io',
        kind: 'HTTPRoute',
        namespace: (import 'app.json5').namespace,
      },
    ],
    to: [
      {
        group: '',
        kind: 'Service',
      },
    ],
  },
}
