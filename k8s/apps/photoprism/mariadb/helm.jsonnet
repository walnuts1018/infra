(import '../../../components/helm.libsonnet') {
  name: (import '../app.json5').name + '-mariadb',
  namespace: (import '../app.json5').namespace,
  chart: 'mariadb',
  repoURL: 'https://charts.bitnami.com/bitnami',
  targetRevision: '20.1.0',
  values: (importstr 'values.yaml'),
}
