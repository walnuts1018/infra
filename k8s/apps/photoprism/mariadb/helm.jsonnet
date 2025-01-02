(import '../../../components/helm.libsonnet') {
  name: (import '../app.json5').name + '-mariadb',
  namespace: (import '../app.json5').namespace,
  chart: 'mariadb',
  repoURL: 'registry-1.docker.io/bitnamicharts',
  targetRevision: '20.0.0',
  values: (importstr 'values.yaml'),
}
