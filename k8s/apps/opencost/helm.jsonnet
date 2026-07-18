local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'opencost',
  repoURL: 'https://opencost.github.io/opencost-helm-chart',
  targetRevision: '2.5.27',
  values: (importstr 'values.yaml'),
}
