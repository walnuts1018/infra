local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  ociChartURL: 'ghcr.io/dependencytrack/helm-charts/dependency-track',
  targetRevision: '2.9.0',
  values: (importstr 'values.yaml'),
} + {
  metadata+: {
    annotations+: {
      'argocd.argoproj.io/sync-wave': '0',
      'argocd.argoproj.io/sync-options': 'SkipHealthCheck=true',
    },
  },
}
