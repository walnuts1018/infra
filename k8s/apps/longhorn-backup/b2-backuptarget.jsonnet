{
  apiVersion: 'longhorn.io/v1beta2',
  kind: 'BackupTarget',
  metadata: {
    name: 'b2',
    namespace: 'longhorn-system',
  },
  spec: {
    backupTargetURL: 's3://walnuts-longhorn-backup-8fvzu3@us-west-004',
    credentialSecret: 'b2-secret',
  },
}
