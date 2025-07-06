{
  apiVersion: 'barmancloud.cnpg.io/v1',
  kind: 'ObjectStore',
  metadata: {
    name: 'minio-store',
  },
  spec: {
    configuration: {
      destinationPath: 's3://cloudnative-pg-backup/',
      endpointURL: 'http://minio.minio.svc.cluster.local:9000',
      s3Credentials: {

      },
      wal: {
        compression: 'gzip',
      },
    },
    retentionPolicy: '14d',
  },
}
