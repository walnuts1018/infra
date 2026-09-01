{
  env: [
    { name: 'AWS_WEB_IDENTITY_TOKEN_FILE', value: '/var/run/secrets/sts.seaweedfs.com/serviceaccount/token' },
    { name: 'AWS_ENDPOINT_URL_STS', value: 'http://seaweedfs-default-filer.seaweedfs.svc.cluster.local:8333' },
    { name: 'AWS_ROLE_ARN', value: 'arn:aws:iam::role/maps' },
  ],
  volumes: [
    {
      name: 'seaweedfs-sts-token',
      projected: {
        sources: [
          {
            serviceAccountToken: {
              audience: 'sts.seaweedfs.com',
              expirationSeconds: 86400,
              path: 'token',
            },
          },
        ],
      },
    },
  ],
  volumeMounts: [
    {
      name: 'seaweedfs-sts-token',
      mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
      readOnly: true,
    },
  ],
}
