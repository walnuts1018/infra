(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,
  chart: 'argocd-image-updater',
  repoURL: 'https://argoproj.github.io/argo-helm',
  targetRevision: '0.11.1',
  values: (importstr 'values.yaml'),
}
