local app = import 'app.json5';
{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'S3Credentials',
  metadata: {
    name: 'cloudnative-pg-backup',
    namespace: app.namespace,
  },
  spec: {
    seaweedRef: {
      name: app.name,
    },
    identityRef: {
      name: 'cloudnative-pg-backup',
    },
    secretRef: {
      name: 'seaweedfs-biscuit-cloudnative-pg-backup-credentials',
      accessKeyField: 'accesskey',
      secretKeyField: 'secretkey',
    },
    reclaimPolicy: 'Retain',
  },
}
