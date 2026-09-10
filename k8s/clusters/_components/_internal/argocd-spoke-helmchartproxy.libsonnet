local spokeValues = importstr '../../../_argocd/spoke/values.yaml';
function(cluster, version='10.8.2') {
  apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
  kind: 'HelmChartProxy',
  metadata: {
    name: 'argocd-spoke',
    namespace: cluster.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '21',
    },
  },
  spec: {
    clusterSelector: {
      matchLabels: {
        'argocd-agent.walnuts.dev/enabled': 'true',
        'cluster.x-k8s.io/cluster-name': cluster.name,
      },
    },
    chartName: 'argo-cd',
    repoURL: 'https://argoproj.github.io/argo-helm',
    version: version,
    releaseName: 'argocd',
    namespace: 'argocd',
    // The spoke is only a transport bootstrap. Argo CD takes over after the
    // agent has registered with the berry Principal.
    reconcileStrategy: 'InstallOnce',
    options: {
      wait: true,
      install: { createNamespace: true },
    },
    valuesTemplate: spokeValues,
  },
}
