{
  securityContext: {
    readOnlyRootFilesystem: true,
    seccompProfile: {
      type: 'RuntimeDefault',
    },
  },
}
