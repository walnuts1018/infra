{
  apiVersion: 'gateway.pomerium.io/v1alpha1',
  kind: 'PolicyFilter',
  metadata: {
    name: (import 'app.json5').name + '-public',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    ppl: |||
      allow:
        and:
          - accept:
              is: true
    |||,
  },
}
