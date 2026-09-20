function(name, destinations, labels={})
  {
    apiVersion: 'argoproj.io/v1alpha1',
    kind: 'AppProject',
    metadata: {
      name: name,
      namespace: (import 'app.json5').namespace,
      annotations: {
        local slackChannel = 'argocd',
        'notifications.argoproj.io/subscribe.on-deleted.slack': slackChannel,
        'notifications.argoproj.io/subscribe.on-health-degraded.slack': slackChannel,
        'notifications.argoproj.io/subscribe.on-sync-failed.slack': slackChannel,
        'notifications.argoproj.io/subscribe.on-sync-succeeded.slack': slackChannel,
      },
      [if std.length(labels) > 0 then 'labels']: labels,
    },
    spec: {
      clusterResourceWhitelist: [{ group: '*', kind: '*' }],
      destinations: destinations,
      sourceNamespaces: ['*'],
      orphanedResources: { warn: false },
      sourceRepos: ['*'],
    },
  }
