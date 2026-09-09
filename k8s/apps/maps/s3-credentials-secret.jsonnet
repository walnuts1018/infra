local s3Credentials = (import '../../components/seaweedfs-s3-credentials.libsonnet')('maps_read');
{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: s3Credentials.secretName,
    namespace: s3Credentials.namespace,
  },
}
