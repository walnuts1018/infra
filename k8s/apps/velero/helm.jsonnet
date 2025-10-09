(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'velero',
  repoURL: 'https://vmware-tanzu.github.io/helm-charts',
  targetRevision: '11.0.0',
  valuesObject: std.mergePatch(
    std.parseYaml(importstr 'values.yaml'), {
      configuration: {
        backupStorageLocation: [
          {
            name: 'minio-biscuit',
            default: true,
            provider: 'aws',
            bucket: 'velero-backup',
            config: {
              s3Url: 'http://minio-biscuit.walnuts.dev',
              region: 'ap-northeast-1',
            },
            credential: {
              name: (import 'external-secret.jsonnet').spec.target.name,
              key: 'credentials',
            },
          },
        ],
        volumeSnapshotLocation: [
          {
            name: 'minio-biscuit',
            provider: 'aws',
            config: {
              s3Url: 'http://minio-biscuit.walnuts.dev',
              region: 'ap-northeast-1',
            },
            credential: {
              name: (import 'external-secret.jsonnet').spec.target.name,
              key: 'credentials',
            },
          },
        ],
      },
    }
  ),
}
