local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
local values = importstr 'values.yaml';
local externalSecret = import 'external-secret.jsonnet';
(helm) {
  name: app.name,
  namespace: app.namespace,
  chart: 'velero',
  repoURL: 'https://vmware-tanzu.github.io/helm-charts',
  targetRevision: '12.0.3',
  valuesObject: std.mergePatch(
    std.parseYaml(values), {
      configuration: {
        backupStorageLocation: [
          {
            name: 'minio-biscuit',
            default: true,
            provider: 'aws',
            bucket: 'velero-backup',
            config: {
              s3Url: 'https://minio-biscuit.local.walnuts.dev',
              region: 'ap-northeast-1',
              s3ForcePathStyle: 'true',
            },
            credential: {
              name: externalSecret.spec.target.name,
              key: 'credentials',
            },
          },
        ],
        volumeSnapshotLocation: [
          {
            name: 'minio-biscuit',
            provider: 'aws',
            config: {
              s3Url: 'https://minio-biscuit.local.walnuts.dev',
              region: 'ap-northeast-1',
              s3ForcePathStyle: 'true',
            },
            credential: {
              name: externalSecret.spec.target.name,
              key: 'credentials',
            },
          },
        ],
      },
    }
  ),
}
