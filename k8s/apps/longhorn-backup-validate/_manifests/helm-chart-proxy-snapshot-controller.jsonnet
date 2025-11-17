{
  apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
  kind: 'HelmChartProxy',
  metadata: {
    name: 'snapshot-controller',
    namespace: (import '../app.json5').namespace,
  },
  spec: {
    clusterSelector: {
      matchLabels: (import 'cluster.jsonnet').metadata.labels,
    },
    repoURL: 'https://piraeus.io/helm-charts/',
    chartName: 'snapshot-controller',
    version: '4.2.0',
    releaseName: 'snapshot-controller',
    namespace: 'kube-system',
    options: {
      waitForJobs: true,
      atomic: true,
      wait: true,
      timeout: '5m',
      install: {
        includeCRDs: true,
      },
    },
    // valuesTemplate: (importstr 'snapshot-controller-values.yaml'),
  },
}
