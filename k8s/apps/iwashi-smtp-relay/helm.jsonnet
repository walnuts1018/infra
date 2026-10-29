local app = import 'app.json5';
(import '../../components/helm.libsonnet') {
  name: app.name,
  namespace: app.namespace,
  chart: 'mail',
  repoURL: 'https://bokysan.github.io/docker-postfix',
  targetRevision: '5.2.0',
  values: (importstr 'values.yaml'),
}
