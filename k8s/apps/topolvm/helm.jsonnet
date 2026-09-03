local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'topolvm',
  repoURL: 'https://topolvm.github.io/topolvm',
  targetRevision: '17.2.0',
  valuesObject: std.parseYaml(importstr 'values.yaml'),
}
