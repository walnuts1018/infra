local cluster = import 'cluster.json5';
{
  apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
  kind: 'HelmChartProxy',
  metadata: {
    name: 'argocd-agent',
    namespace: cluster.namespace,
  },
  spec: {
    clusterSelector: {
      matchLabels: {
        'argocd-agent.walnuts.dev/enabled': 'true',
      },
    },
    chartName: 'argocd-agent-agent',
    repoURL: 'oci://ghcr.io/argoproj-labs/argocd-agent',
    version: '0.2.7',
    releaseName: 'argocd-agent',
    namespace: 'argocd',
    reconcileStrategy: 'Continuous',
    options: {
      wait: false,
      install: { createNamespace: true },
    },
    valuesTemplate: importstr '../../_argocd/agent/agent/values.yaml',
  },
}
