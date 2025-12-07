{
  apiVersion: 'sts.min.io/v1alpha1',
  kind: 'PolicyBinding',
  metadata: {
    name: (import 'app.json5').name + '-executor',
    namespace: (import '../minio/app.json5').namespace,
  },
  spec: {
    application: {
      namespace: (import 'app.json5').namespace,
      serviceaccount: (import 'sa-executor.jsonnet').metadata.name,
    },
    policies: [
      'readwrite',
    ],
  },
}
