local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,

  chart: 'prometheus-operator-crds',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '30.0.1',
}
