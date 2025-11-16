{
  apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
  kind: 'HelmChartProxy',
  metadata: {
    name: 'velero',
  },
  spec: {
    clusterSelector: {
      matchLabels: {
        'cluster.x-k8s.io/cluster-name': (import '../longhorn-backup-validate/cluster.jsonnet').metadata.name,
      },
    },
    repoURL: 'https://vmware-tanzu.github.io/helm-charts',
    chartName: 'velero',
    version: '11.1.1',
    releaseName: 'velero',
    namespace: 'velero',
    options: {
      waitForJobs: true,
      atomic: true,
      wait: true,
      timeout: '5m',
      install: {
        createNamespace: true,
        includeCRDs: true,
      },
    },
    valuesTemplate: (importstr 'velero-values.yaml'),
  },
}
