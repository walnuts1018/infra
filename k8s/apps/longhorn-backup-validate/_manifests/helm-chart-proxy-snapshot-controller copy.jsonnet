{
  apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
  kind: 'HelmChartProxy',
  metadata: {
    name: 'snapshot-controller-crds',
    namespace: (import '../app.json5').namespace,
  },
  spec: {
    clusterSelector: {
      matchLabels: (import 'cluster.jsonnet').metadata.labels,
    },
    repoURL: 'https://wiremind.github.io/wiremind-helm-charts',
    chartName: 'snapshot-controller-crds',
    version: '8.4.0',
    releaseName: 'snapshot-controller-crds',
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
    // valuesTemplate: (importstr 'snapshot-controller-crds-values.yaml'),
  },
}
