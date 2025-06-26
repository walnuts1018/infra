{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: 'storage-configuration',
    namespace: 'minio-tenant',
  },
  type: 'Opaque',
  stringData: {
    'config.env': 'export MINIO_ROOT_USER="minio"\nexport MINIO_ROOT_PASSWORD="minio123"',
  },
}
