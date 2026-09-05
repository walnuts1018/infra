{
  apiVersion: 'gateway.networking.k8s.io/v1beta1',
  kind: 'ReferenceGrant',
  metadata: {
    name: 'prfexample-allow-interceptor',
    namespace: 'keda',
  },
  spec: {
    from: [
      {
        group: 'gateway.networking.k8s.io',
        kind: 'HTTPRoute',
        namespace: 'prfexample',
      },
    ],
    to: [
      {
        group: '',
        kind: 'Service',
        name: 'keda-add-ons-http-interceptor-proxy',
      },
    ],
  },
}
