{
  apiVersion: 'sts.min.io/v1alpha1',
  kind: 'PolicyBinding',
  metadata: {
    name: (import 'app.json5').name,
    namespace: (import '../minio/app.json5').namespace,
  },
  spec: {
    application: {
      namespace: (import 'app.json5').namespace,
      serviceaccount: (import 'postgres.jsonnet').metadata.name,
    },
    policies: [
      'readwrite',
    ],
  },
}
