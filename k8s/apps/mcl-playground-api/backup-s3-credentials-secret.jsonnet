local credentials = (import '../../components/seaweedfs-s3-credentials.libsonnet')('mcl_playground_backup');
{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: credentials.secretName,
    namespace: credentials.namespace,
  },
}
