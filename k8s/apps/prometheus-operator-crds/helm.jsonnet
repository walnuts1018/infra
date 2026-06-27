local helm = import '../../components/helm.libsonnet';
local app = import 'app.json5';
(helm) {
  name: app.name,
  namespace: app.namespace,

  chart: 'prometheus-operator-crds',
  repoURL: 'https://prometheus-community.github.io/helm-charts',
  targetRevision: '29.0.0',
}
