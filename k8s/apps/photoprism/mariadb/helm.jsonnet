(import '../../../components/helm.libsonnet') {
  name: (import '../app.json5').name + '-mariadb',
  namespace: (import '../app.json5').namespace,
  ociChartURL: 'registry-1.docker.io/bitnamicharts/mariadb',
  targetRevision: '21.0.1',
  values: (importstr 'values.yaml'),
}
