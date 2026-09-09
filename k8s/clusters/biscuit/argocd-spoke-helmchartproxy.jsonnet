local cluster = import 'cluster.json5';
{
  apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
  kind: 'HelmChartProxy',
  metadata: {
    name: 'argocd-spoke',
    namespace: cluster.namespace,
  },
  spec: {
    clusterSelector: {
      matchLabels: {
        'argocd-agent.walnuts.dev/enabled': 'true',
      },
    },
    chartName: 'argo-cd',
    repoURL: 'https://argoproj.github.io/argo-helm',
    version: '10.8.2',
    releaseName: 'argocd',
    namespace: 'argocd',
    reconcileStrategy: 'Continuous',
    options: {
      wait: true,
      install: { createNamespace: true },
    },
    valuesTemplate: importstr '../../_argocd/spoke/values.yaml',
  },
}
