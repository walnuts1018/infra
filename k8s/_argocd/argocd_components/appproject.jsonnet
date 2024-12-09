{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'AppProject',
  metadata: {
    name: 'default',
    namespace: (import 'app.json5').namespace,
    annotations: {
      local slackChannel = 'walnuts-sysop',
      'notifications.argoproj.io/subscribe.on-deleted.slack': slackChannel,
      'notifications.argoproj.io/subscribe.on-health-degraded.slack': slackChannel,
      'notifications.argoproj.io/subscribe.on-sync-failed.slack': slackChannel,
    },
  },
  spec: {
    clusterResourceWhitelist: [
      {
        group: '*',
        kind: '*',
      },
    ],
    destinations: [
      {
        namespace: '*',
        server: '*',
      },
    ],
    orphanedResources: {
      warn: true,
    },
    sourceRepos: [
      '*',
    ],
  },
}
