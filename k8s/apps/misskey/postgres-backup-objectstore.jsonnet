{
  apiVersion: 'barmancloud.cnpg.io/v1',
  kind: 'ObjectStore',
  metadata: {
    name: 'minio-store',
    namespace: (import 'app.json5').namespace,
  },
  spec: {
    configuration: {
      destinationPath: 's3://cloudnative-pg-backup/' + (import 'postgres.jsonnet').metadata.name + '/',
      endpointURL: 'http://minio.minio.svc.cluster.local:9000',
      s3Credentials: {
        inheritFromIAMRole: true,
      },
      wal: {
        compression: 'gzip',
      },
    },
    retentionPolicy: '14d',
  },
}
