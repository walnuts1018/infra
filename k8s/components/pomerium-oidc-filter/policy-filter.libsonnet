{
  name:: error 'name is required',
  namespace:: error 'namespace is required',
  allowedGroup:: error 'allowedGroups is required',

  apiVersion: 'gateway.pomerium.io/v1alpha1',
  kind: 'PolicyFilter',
  metadata: {
    name: $.name,
    namespace: $.namespace,
  },
  spec: {
    ppl: |||
      allow:
        and:
          - groups:
              has: %s
    ||| % [$.allowedGroup],
  },
}
