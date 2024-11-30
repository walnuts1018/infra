(import '../../../components/helm.libsonnet') {
  name: (import '../app.json5').name + '-mariadb',
  namespace: (import '../app.json5').namespace,
  chart: 'mariadb',
  repoURL: 'oci://registry-1.docker.io/bitnamicharts/mariadb',
  targetRevision: '20.1.1',
  values: (importstr 'values.yaml'),
}
