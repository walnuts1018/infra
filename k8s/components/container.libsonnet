{
  securityContext: {
    readOnlyRootFilesystem: true,
    seccompProfile: {
      type: 'RuntimeDefault',
    },
    capabilities: {
      add: ['NET_BIND_SERVICE'],
      drop: [
        'all',
      ],
    },
  },
}
