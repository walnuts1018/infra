[
  {
    apiVersion: 'sts.min.io/v1alpha1',
    kind: 'PolicyBinding',
    metadata: {
      name: 'static-web',
      namespace: (import 'app.json5').namespace,
    },
    spec: {
      application: {
        namespace: (import '../static/app.json5').namespace,
        serviceaccount: (import '../static/sa.jsonnet').metadata.name,
      },
      policies: [
        'readonly',
      ],
    },
  },
]
