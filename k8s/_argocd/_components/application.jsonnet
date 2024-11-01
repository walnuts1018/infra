(import '../../common/application-with-helm.libsonnet') {
  name: (import 'app.libsonnet').appname,
  namespace: (import 'app.libsonnet').namespace,
  chart: 'argo-cd',
  repoURL: 'https://argoproj.github.io/argo-helm',
  targetRevision: '7.6.12',
  values: (importstr 'values.yaml'),
}
