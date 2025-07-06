local bindings = [
  {
    sa: (import '../ipu/sa.jsonnet').metadata,
    policies: [
      'readonly',
    ],
  },
  {
    sa: {
      name: 'loki',
      namespace: (import '../loki/app.json5').namespace,
    },
    policies: [
      'readwrite',
    ],
  },
  {
    sa: {
      name: 'tempo',
      namespace: (import '../tempo/app.json5').namespace,
    },
    policies: [
      'readwrite',
    ],
  },
  {
    sa: (import '../misskey/postgres.jsonnet').spec.serviceAccountTemplate.metadata,
    policies: [
      'readwrite',
    ],
  },
];

// template for PolicyBinding
[
  {
    apiVersion: 'sts.min.io/v1alpha1',
    kind: 'PolicyBinding',
    metadata: {
      name: binding.sa.name,
      namespace: (import 'app.json5').namespace,
    },
    spec: {
      application: {
        namespace: binding.sa.namespace,
        serviceaccount: binding.sa.name,
      },
      policies: binding.policies,
    },
  }
  for binding in bindings
]
