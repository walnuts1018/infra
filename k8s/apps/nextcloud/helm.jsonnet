(import '../../components/helm.libsonnet') {
  name: (import 'app.json5').name,
  namespace: (import 'app.json5').namespace,

  chart: 'nextcloud',
  repoURL: 'https://nextcloud.github.io/helm/',
  targetRevision: '7.0.0',
  values: (importstr 'values.yaml'),
}
