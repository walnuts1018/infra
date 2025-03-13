(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'nextcloud',
  repoURL: 'https://nextcloud.github.io/helm/',
  targetRevision: '6.6.9',
  values: (importstr 'values.yaml'),
}
