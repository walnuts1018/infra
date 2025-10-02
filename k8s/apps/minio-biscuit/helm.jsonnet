(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'tenant',
  repoURL: 'https://operator.min.io/',
  targetRevision: '7.1.1',
  valuesObject: std.mergePatch(std.parseYaml(importstr 'values.yaml'), {
    tenant: {
      configSecret: {
        name: (import 'storage-configuration.jsonnet').spec.target.name,
      },
      local region = 'ap-northeast-1',
      buckets: [
        { name: bucket_name, region: region }
        for bucket_name in (import 'buckets.json5')
      ],
    },
  }),
}
