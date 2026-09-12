local agentValues = importstr '../../../_argocd/agent/agent/values.yaml';
function(cluster, version='0.2.7') {
  apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
  kind: 'HelmChartProxy',
  metadata: {
    name: 'argocd-agent',
    namespace: cluster.namespace,
    annotations: {
    },
  },
  spec: {
    clusterSelector: {
      matchLabels: {
        'argocd-agent.walnuts.dev/enabled': 'true',
        'cluster.x-k8s.io/cluster-name': cluster.name,
      },
    },
    chartName: 'argocd-agent-agent',
    repoURL: 'oci://ghcr.io/argoproj-labs/argocd-agent',
    version: version,
    releaseName: 'argocd-agent',
    namespace: 'argocd',
    reconcileStrategy: 'InstallOnce',
    options: {
      wait: false,
      install: { createNamespace: true },
    },
    valuesTemplate: agentValues,
  },
}
