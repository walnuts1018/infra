{
  securityContext: {
    readOnlyRootFilesystem: true,
    seccompProfile: {
      type: 'RuntimeDefault',
    },
    capabilities: {
      drop: [
        'all',
      ],
    },
  },
}
