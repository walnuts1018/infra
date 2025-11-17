{
  apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
  kind: 'HelmChartProxy',
  metadata: {
    name: 'longhorn',
  },
  spec: {
    clusterSelector: {
      matchLabels: (import 'cluster.jsonnet').metadata.labels,
    },
    repoURL: 'https://charts.longhorn.io',
    chartName: 'longhorn',
    version: '1.10.1',
    releaseName: 'longhorn',
    namespace: 'longhorn-system',
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
    valuesTemplate: (importstr 'longhorn-values.yaml'),
  },
}
