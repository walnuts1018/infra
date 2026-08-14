local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'reloader',
  repoURL: 'https://stakater.github.io/stakater-charts',
  targetRevision: '2.2.16',
}
