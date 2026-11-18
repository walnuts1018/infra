{
  securityContext: {
    allowPrivilegeEscalation: false,
    capabilities: { drop: ['ALL'] },
    readOnlyRootFilesystem: true,
    runAsGroup: 10001,
    runAsNonRoot: true,
    runAsUser: 10001,
  },
  volumeMounts: [
    {
      name: 'sts-token',
      mountPath: '/var/run/secrets/sts.seaweedfs.com/serviceaccount',
      readOnly: true,
    },
    { name: 'tmp', mountPath: '/tmp' },
  ],
  volumes(tmpSize): [
    {
      name: 'sts-token',
      projected: {
        sources: [{
          serviceAccountToken: {
            audience: 'sts.seaweedfs.com',
            expirationSeconds: 3600,
            path: 'token',
          },
        }],
      },
    },
    { name: 'tmp', emptyDir: { sizeLimit: tmpSize } },
  ],
}
