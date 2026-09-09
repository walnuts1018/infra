{
  apiVersion: 'argoproj.io/v1alpha1',
  kind: 'AppProject',
  metadata: {
    name: 'kurumi',
    namespace: (import 'app.json5').namespace,
    annotations: {
      local slackChannel = 'argocd',
      'notifications.argoproj.io/subscribe.on-deleted.slack': slackChannel,
      'notifications.argoproj.io/subscribe.on-health-degraded.slack': slackChannel,
      'notifications.argoproj.io/subscribe.on-sync-failed.slack': slackChannel,
      'notifications.argoproj.io/subscribe.on-sync-succeeded.slack': slackChannel,
    },
    labels: { 'argocd-agent': 'true' },
  },
  spec: {
    clusterResourceWhitelist: [{ group: '*', kind: '*' }],
    destinations: [{ namespace: '*', name: 'kurumi' }],
    sourceNamespaces: ['*'],
    orphanedResources: { warn: false },
    sourceRepos: [
      'https://github.com/walnuts1018/infra',
      'https://github.com/walnuts1018/infra-private',
      'https://github.com/argoproj-labs/argocd-agent',
      'https://argoproj.github.io/argo-helm',
    ],
  },
}
