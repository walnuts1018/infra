{
  priorityClassName: 'agr-learning',
  securityContext: {
    runAsNonRoot: true,
    runAsUser: 10001,
    runAsGroup: 10001,
    seccompProfile: { type: 'RuntimeDefault' },
  },
}
