{
  apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
  kind: 'HelmChartProxy',
  metadata: {
    name: 'longhorn',
  },
  spec: {
    clusterSelector: {
      matchLabels: {
        'cluster.x-k8s.io/cluster-name': (import 'app.json5').name,
      },
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
