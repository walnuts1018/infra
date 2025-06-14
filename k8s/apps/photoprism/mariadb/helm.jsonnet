(import '../../../components/helm.libsonnet') {
  name: (import '../app.json5').name + '-mariadb',
  namespace: (import '../app.json5').namespace,
  ociChartURL: 'registry-1.docker.io/bitnamicharts/mariadb',
  targetRevision: '20.5.9',
  values: (importstr 'values.yaml'),
}
