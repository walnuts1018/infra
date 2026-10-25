local app = import 'app.json5';
local apiCredentials = (import '../../components/seaweedfs-s3-credentials.libsonnet')('mcl_playground');
local backupCredentials = (import '../../components/seaweedfs-s3-credentials.libsonnet')('mcl_playground_backup');
{
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'ResourceReferenceGrant',
  metadata: {
    name: 'seaweedfs-s3-credentials',
    namespace: app.namespace,
  },
  spec: {
    from: [
      {
        group: 'seaweed.seaweedfs.com',
        kind: 'S3Credentials',
        namespace: 'seaweedfs',
      },
    ],
    to: [
      {
        group: '',
        kind: 'Secret',
        name: apiCredentials.secretName,
      },
      {
        group: '',
        kind: 'Secret',
        name: backupCredentials.secretName,
      },
    ],
  },
}
