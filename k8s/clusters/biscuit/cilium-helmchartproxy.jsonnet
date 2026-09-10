local cluster = import 'cluster.json5';
{
  apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
  kind: 'HelmChartProxy',
  metadata: {
    name: 'cilium-bootstrap',
    namespace: cluster.namespace,
    annotations: {
      'argocd.argoproj.io/sync-wave': '20',
    },
  },
  spec: {
    clusterSelector: {
      matchLabels: {
        'argocd-agent.walnuts.dev/enabled': 'true',
      },
    },
    chartName: 'cilium',
    repoURL: 'https://helm.cilium.io/',
    version: '1.20.1',
    releaseName: 'cilium',
    namespace: 'cilium-system',
    reconcileStrategy: 'InstallOnce',
    options: {
      wait: true,
      install: { createNamespace: true },
    },
    valuesTemplate: importstr '../../apps/cilium/values.biscuit.yaml',
  },
}
