[
  {
    apiVersion: 'sts.min.io/v1alpha1',
    kind: 'PolicyBinding',
    metadata: {
      name: 'ipu',
      namespace: (import 'app.json5').namespace,
    },
    spec: {
      application: {
        namespace: (import '../ipu/app.json5').namespace,
        serviceaccount: (import '../ipu/sa.jsonnet').metadata.name,
      },
      policies: [
        'readonly',
      ],
    },
  },
]
