local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,

  chart: 'zitadel',
  repoURL: 'https://charts.zitadel.com',
  targetRevision: '10.3.0',
  values: (importstr 'values.yaml'),
}
