local bindings = [
  {
    sa: (import '../ipu/sa.jsonnet'),
    policies: [
      'readonly',
    ],
  },
];

// template for PolicyBinding
[
  {
    apiVersion: 'sts.min.io/v1alpha1',
    kind: 'PolicyBinding',
    metadata: {
      name: binding.sa.metadata.name,
      namespace: (import 'app.json5').namespace,
    },
    spec: {
      application: {
        namespace: binding.sa.metadata.namespace,
        serviceaccount: binding.sa.metadata.name,
      },
      policies: binding.policies,
    },
  }
  for binding in bindings
]
