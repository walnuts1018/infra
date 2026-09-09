{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'AppProject',
  metadata: {
    name: 'berry',
    namespace: (import 'app.json5').namespace,
    annotations: {
      local slackChannel = 'argocd',
      'notifications.argoproj.io/subscribe.on-deleted.slack': slackChannel,
      'notifications.argoproj.io/subscribe.on-health-degraded.slack': slackChannel,
      'notifications.argoproj.io/subscribe.on-sync-failed.slack': slackChannel,
      'notifications.argoproj.io/subscribe.on-sync-succeeded.slack': slackChannel,
    },
  },
  spec: {
    clusterResourceWhitelist: [{ group: '*', kind: '*' }],
    destinations: [{ namespace: '*', server: 'https://kubernetes.default.svc' }],
    sourceNamespaces: ['*'],
    orphanedResources: { warn: false },
    // app.json5 is the trusted source-of-truth for external charts and
    // multi-source Applications. Restricting this list to the bootstrap
    // repositories makes every external chart fail Project validation.
    sourceRepos: ['*'],
  },
}
