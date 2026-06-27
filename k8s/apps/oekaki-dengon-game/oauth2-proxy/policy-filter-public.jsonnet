local app = import '../app.json5';
{
  apiVersion: 'gateway.pomerium.io/v1alpha1',
  kind: 'PolicyFilter',
  metadata: {
    name: app.name + '-public',
    namespace: app.namespace,
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
