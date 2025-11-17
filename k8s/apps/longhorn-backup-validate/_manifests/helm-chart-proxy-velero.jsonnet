{
  apiVersion: 'addons.cluster.x-k8s.io/v1alpha1',
  kind: 'HelmChartProxy',
  metadata: {
    name: 'velero',
    namespace: (import '../app.json5').namespace,
  },
  spec: {
    clusterSelector: {
      matchLabels: (import 'cluster.jsonnet').metadata.labels,
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
      // install: {
      //   includeCRDs: true,
      // },
    },
    valuesTemplate: (importstr 'velero-values.yaml'),
  },
}
