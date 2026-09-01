function(namespace) {
  apiVersion: 'seaweed.seaweedfs.com/v1',
  kind: 'ResourceReferenceGrant',
  metadata: {
    name: 'seaweedfs-s3-credentials',
    namespace: namespace,
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
      },
    ],
  },
}
